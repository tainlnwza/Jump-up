#if UNITY_EDITOR
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// Unity MCP Bridge - Model Context Protocol Server for Unity Editor
/// Enables AI assistants (Antigravity, Claude, Cursor) to interact with Unity Editor.
/// Listens on http://localhost:8080/
/// </summary>
[InitializeOnLoad]
public static class UnityMcpBridge
{
    private const string PORT_PREF_KEY = "UnityMcp_Port";
    private const int DEFAULT_PORT = 8080;
    
    private static HttpListener listener;
    private static Thread serverThread;
    private static bool isRunning = false;
    
    // Main-thread execution queue (Unity API calls MUST run on main thread)
    private static readonly ConcurrentQueue<Action> mainThreadQueue = new ConcurrentQueue<Action>();
    
    // Console log ring-buffer
    private static readonly List<LogEntry> consoleLogs = new List<LogEntry>();
    private const int MAX_LOGS = 100;
    private static readonly object logLock = new object();

    [Serializable]
    public class LogEntry
    {
        public string type;
        public string message;
        public string stackTrace;
        public string timestamp;
    }

    static UnityMcpBridge()
    {
        // Subscribe to main-thread update loop and log callback
        EditorApplication.update -= Update;
        EditorApplication.update += Update;

        Application.logMessageReceivedThreaded -= OnLogReceived;
        Application.logMessageReceivedThreaded += OnLogReceived;

        // Clean up before assembly reloads
        AssemblyReloadEvents.beforeAssemblyReload -= StopServer;
        AssemblyReloadEvents.beforeAssemblyReload += StopServer;

        // Auto-start server when Editor loads
        EditorApplication.delayCall += () =>
        {
            if (!isRunning)
            {
                StartServer();
            }
        };
    }

    private static int GetPort()
    {
        return EditorPrefs.GetInt(PORT_PREF_KEY, DEFAULT_PORT);
    }

    private static void SetPort(int port)
    {
        EditorPrefs.SetInt(PORT_PREF_KEY, port);
    }

    #region Menu Items
    [MenuItem("MCP/Start MCP Server", false, 1)]
    public static void StartServerMenu()
    {
        StartServer();
    }

    [MenuItem("MCP/Stop MCP Server", false, 2)]
    public static void StopServerMenu()
    {
        StopServer();
    }

    [MenuItem("MCP/Check Server Status", false, 3)]
    public static void CheckStatusMenu()
    {
        int port = GetPort();
        if (isRunning)
        {
            EditorUtility.DisplayDialog(
                "MCP Server Status",
                $"✅ Unity MCP Bridge is RUNNING on:\nhttp://localhost:{port}/\n\nAI assistants can now connect to this Unity Editor.",
                "OK"
            );
        }
        else
        {
            bool start = EditorUtility.DisplayDialog(
                "MCP Server Status",
                $"❌ Unity MCP Bridge is STOPPED.\nWould you like to start it on port {port}?",
                "Start Server", "Cancel"
            );
            if (start) StartServer();
        }
    }

    [MenuItem("MCP/Copy MCP Config for IDE", false, 20)]
    public static void CopyMcpConfig()
    {
        int port = GetPort();
        string config = $@"{{
  ""mcpServers"": {{
    ""unity"": {{
      ""command"": ""npx"",
      ""args"": [""-y"", ""unity-mcp-server""],
      ""env"": {{
        ""UNITY_PORT"": ""{port}"",
        ""UNITY_URL"": ""http://localhost:{port}""
      }}
    }}
  }}
}}";
        EditorGUIUtility.systemCopyBuffer = config;
        EditorUtility.DisplayDialog("Config Copied", "MCP configuration copied to clipboard!\nYou can paste this into your MCP settings.", "OK");
    }

    [MenuItem("MCP/Actions/Move Cube Left 10", false, 50)]
    public static void MoveCubeLeft10()
    {
        var cube = GameObject.Find("Cube");
        if (cube != null)
        {
            Undo.RecordObject(cube.transform, "Move Cube Left 10");
            cube.transform.position += Vector3.left * 10f;
            EditorUtility.SetDirty(cube);
            Debug.Log($"<color=#4CAF50>[Unity MCP Bridge] Moved Cube to {cube.transform.position}</color>");
        }
        else
        {
            Debug.LogWarning("[Unity MCP Bridge] GameObject 'Cube' not found in active scene.");
        }
    }
    #endregion

    #region Server Lifecycle
    public static void StartServer()
    {
        if (isRunning) return;

        int port = GetPort();
        try
        {
            if (listener != null)
            {
                try { listener.Stop(); listener.Close(); } catch { }
                listener = null;
            }

            listener = new HttpListener();
            listener.Prefixes.Add($"http://localhost:{port}/");
            listener.Start();
            isRunning = true;

            serverThread = new Thread(ServerWorker)
            {
                IsBackground = true,
                Name = "UnityMcpServerThread"
            };
            serverThread.Start();

            Debug.Log($"<color=#4CAF50><b>[Unity MCP Bridge]</b> Server started on http://localhost:{port}/</color>");
        }
        catch (Exception ex)
        {
            isRunning = false;
            Debug.LogError($"[Unity MCP Bridge] Failed to start server on port {port}: {ex.Message}");
        }
    }

    public static void StopServer()
    {
        if (!isRunning) return;

        isRunning = false;
        try
        {
            listener?.Stop();
            listener?.Close();
            listener = null;
        }
        catch { }

        Debug.Log("[Unity MCP Bridge] Server stopped.");
    }

    private static void ServerWorker()
    {
        while (isRunning && listener != null && listener.IsListening)
        {
            try
            {
                var context = listener.GetContext();
                ThreadPool.QueueUserWorkItem((_) => ProcessRequest(context));
            }
            catch (HttpListenerException)
            {
                // Normal when listener is stopped
                break;
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[Unity MCP Bridge] Worker error: {ex.Message}");
            }
        }
    }
    #endregion

    #region Main Thread Dispatcher
    private static void Update()
    {
        while (mainThreadQueue.TryDequeue(out Action action))
        {
            try
            {
                action?.Invoke();
            }
            catch (Exception ex)
            {
                Debug.LogError($"[Unity MCP Bridge] MainThread error: {ex}");
            }
        }
    }

    private static Task<T> RunOnMainThread<T>(Func<T> func)
    {
        var tcs = new TaskCompletionSource<T>();
        mainThreadQueue.Enqueue(() =>
        {
            try
            {
                T result = func();
                tcs.SetResult(result);
            }
            catch (Exception ex)
            {
                tcs.SetException(ex);
            }
        });
        return tcs.Task;
    }

    private static Task RunOnMainThread(Action action)
    {
        var tcs = new TaskCompletionSource<bool>();
        mainThreadQueue.Enqueue(() =>
        {
            try
            {
                action();
                tcs.SetResult(true);
            }
            catch (Exception ex)
            {
                tcs.SetException(ex);
            }
        });
        return tcs.Task;
    }
    #endregion

    #region Request Routing
    private static void ProcessRequest(HttpListenerContext context)
    {
        HttpListenerRequest req = context.Request;
        HttpListenerResponse res = context.Response;

        // Add CORS Headers
        res.AddHeader("Access-Control-Allow-Origin", "*");
        res.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.AddHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        if (req.HttpMethod == "OPTIONS")
        {
            res.StatusCode = 200;
            res.Close();
            return;
        }

        string path = req.Url.AbsolutePath.ToLower().TrimEnd('/');
        string responseJson = "{}";
        int statusCode = 200;

        try
        {
            string body = "";
            if (req.HasEntityBody)
            {
                using (var reader = new StreamReader(req.InputStream, req.ContentEncoding))
                {
                    body = reader.ReadToEnd();
                }
            }

            switch (path)
            {
                case "":
                case "/status":
                    responseJson = HandleGetStatus().Result;
                    break;

                case "/hierarchy":
                    responseJson = HandleGetHierarchy().Result;
                    break;

                case "/logs":
                case "/console":
                    responseJson = HandleGetLogs();
                    break;

                case "/execute":
                    responseJson = HandleExecute(body).Result;
                    break;

                case "/gameobject/create":
                    responseJson = HandleCreateGameObject(body).Result;
                    break;

                case "/gameobject/inspect":
                    responseJson = HandleInspectGameObject(body).Result;
                    break;

                case "/gameobject/transform":
                case "/gameobject/modify":
                    responseJson = HandleTransformGameObject(body).Result;
                    break;

                case "/gameobject/delete":
                    responseJson = HandleDeleteGameObject(body).Result;
                    break;

                case "/scene/save":
                    responseJson = HandleSaveScene().Result;
                    break;

                case "/battle/status":
                    responseJson = HandleGetBattleStatus().Result;
                    break;

                case "/refresh":
                    responseJson = HandleRefreshAssets().Result;
                    break;

                default:
                    statusCode = 404;
                    responseJson = "{\"error\": \"Endpoint not found\"}";
                    break;
            }
        }
        catch (Exception ex)
        {
            statusCode = 500;
            responseJson = $"{{\"error\": \"{EscapeJson(ex.Message)}\"}}";
        }

        byte[] buffer = Encoding.UTF8.GetBytes(responseJson);
        res.ContentType = "application/json";
        res.ContentLength64 = buffer.Length;
        res.StatusCode = statusCode;
        try
        {
            res.OutputStream.Write(buffer, 0, buffer.Length);
            res.OutputStream.Close();
        }
        catch { }
    }
    #endregion

    #region Endpoint Handlers
    private static async Task<string> HandleGetStatus()
    {
        return await RunOnMainThread(() =>
        {
            Scene activeScene = SceneManager.GetActiveScene();
            return $@"{{
  ""status"": ""online"",
  ""unityVersion"": ""{Application.unityVersion}"",
  ""platform"": ""{Application.platform}"",
  ""isPlaying"": {EditorApplication.isPlaying.ToString().ToLower()},
  ""isPaused"": {EditorApplication.isPaused.ToString().ToLower()},
  ""isCompiling"": {EditorApplication.isCompiling.ToString().ToLower()},
  ""activeScene"": ""{activeScene.name}"",
  ""activeScenePath"": ""{EscapeJson(activeScene.path)}"",
  ""rootObjectCount"": {activeScene.rootCount}
}}";
        });
    }

    private static async Task<string> HandleGetHierarchy()
    {
        return await RunOnMainThread(() =>
        {
            Scene activeScene = SceneManager.GetActiveScene();
            GameObject[] rootObjects = activeScene.GetRootGameObjects();

            var list = new List<string>();
            foreach (var go in rootObjects)
            {
                list.Add(SerializeGameObjectHierarchy(go));
            }

            return $"{{\"scene\": \"{activeScene.name}\", \"objects\": [{string.Join(",", list)}]}}";
        });
    }

    private static string SerializeGameObjectHierarchy(GameObject go)
    {
        var componentNames = new List<string>();
        foreach (var c in go.GetComponents<Component>())
        {
            if (c != null) componentNames.Add($"\"{c.GetType().Name}\"");
        }

        var childList = new List<string>();
        for (int i = 0; i < go.transform.childCount; i++)
        {
            childList.Add(SerializeGameObjectHierarchy(go.transform.GetChild(i).gameObject));
        }

        return $@"{{
  ""name"": ""{EscapeJson(go.name)}"",
  ""instanceId"": {go.GetInstanceID()},
  ""active"": {go.activeSelf.ToString().ToLower()},
  ""tag"": ""{go.tag}"",
  ""layer"": {go.layer},
  ""components"": [{string.Join(",", componentNames)}],
  ""children"": [{string.Join(",", childList)}]
}}";
    }

    private static string HandleGetLogs()
    {
        lock (logLock)
        {
            var items = new List<string>();
            foreach (var log in consoleLogs)
            {
                items.Add($@"{{
  ""type"": ""{log.type}"",
  ""message"": ""{EscapeJson(log.message)}"",
  ""stackTrace"": ""{EscapeJson(log.stackTrace)}"",
  ""timestamp"": ""{log.timestamp}""
}}");
            }
            return $"{{\"logs\": [{string.Join(",", items)}]}}";
        }
    }

    private static async Task<string> HandleExecute(string jsonBody)
    {
        return await RunOnMainThread(() =>
        {
            if (string.IsNullOrEmpty(jsonBody)) return "{\"error\": \"Empty body\"}";

            string action = ExtractStringValue(jsonBody, "action");

            if (action.Equals("play", StringComparison.OrdinalIgnoreCase))
            {
                EditorApplication.isPlaying = true;
                return "{\"success\": true, \"state\": \"playing\"}";
            }
            if (action.Equals("pause", StringComparison.OrdinalIgnoreCase))
            {
                EditorApplication.isPaused = !EditorApplication.isPaused;
                return $"{{\"success\": true, \"isPaused\": {EditorApplication.isPaused.ToString().ToLower()}}}";
            }
            if (action.Equals("stop", StringComparison.OrdinalIgnoreCase))
            {
                EditorApplication.isPlaying = false;
                return "{\"success\": true, \"state\": \"stopped\"}";
            }
            if (action.Equals("setup_player_presence", StringComparison.OrdinalIgnoreCase))
            {
                BattleSystemSetup.SetupPlayerPresence();
                return "{\"success\": true, \"message\": \"SetupPlayerPresence executed\"}";
            }
            if (action.Equals("refresh", StringComparison.OrdinalIgnoreCase))
            {
                AssetDatabase.Refresh();
                return "{\"success\": true, \"message\": \"AssetDatabase refreshed\"}";
            }
            if (action.Equals("move_cube_left", StringComparison.OrdinalIgnoreCase))
            {
                MoveCubeLeft10();
                var cube = GameObject.Find("Cube");
                if (cube != null)
                {
                    Vector3 p = cube.transform.position;
                    return $"{{\"success\": true, \"name\": \"Cube\", \"position\": [{p.x}, {p.y}, {p.z}]}}";
                }
                return "{\"error\": \"Cube not found\"}";
            }

            // Check for menu item execution
            int menuIndex = jsonBody.IndexOf("\"menu\":");
            if (menuIndex >= 0)
            {
                string menuPath = ExtractStringValue(jsonBody, "menu");
                if (!string.IsNullOrEmpty(menuPath))
                {
                    bool executed = EditorApplication.ExecuteMenuItem(menuPath);
                    return $"{{\"success\": {executed.ToString().ToLower()}, \"menu\": \"{EscapeJson(menuPath)}\"}}";
                }
            }

            if (jsonBody.Contains("\"player_action\":"))
            {
                string act = ExtractStringValue(jsonBody, "player_action");
                if (System.Enum.TryParse<PlayerActionType>(act, true, out var actionType))
                {
                    BattleManager.Instance?.ExecuteAction(actionType);
                    var bm = BattleManager.Instance;
                    if (bm != null)
                    {
                        return $"{{\"success\": true, \"action\": \"{actionType}\", \"bossHp\": {bm.bossCurrentHp}, \"playerHp\": {bm.playerCurrentHp}, \"ult\": {bm.ultimateCharge}, \"exp\": {bm.playerExp}}}";
                    }
                    return "{\"error\": \"BattleManager not active\"}";
                }
            }

            return "{\"error\": \"Unrecognized command\"}";
        });
    }

    private static async Task<string> HandleCreateGameObject(string jsonBody)
    {
        return await RunOnMainThread(() =>
        {
            string name = ExtractStringValue(jsonBody, "name");
            if (string.IsNullOrEmpty(name)) name = "New GameObject";

            string primitive = ExtractStringValue(jsonBody, "primitive");
            GameObject go;

            if (primitive.Equals("cube", StringComparison.OrdinalIgnoreCase))
                go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            else if (primitive.Equals("sphere", StringComparison.OrdinalIgnoreCase))
                go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            else if (primitive.Equals("plane", StringComparison.OrdinalIgnoreCase))
                go = GameObject.CreatePrimitive(PrimitiveType.Plane);
            else
                go = new GameObject(name);

            go.name = name;
            Undo.RegisterCreatedObjectUndo(go, "MCP Create GameObject");

            return $@"{{
  ""success"": true,
  ""name"": ""{EscapeJson(go.name)}"",
  ""instanceId"": {go.GetInstanceID()}
}}";
        });
    }

    private static async Task<string> HandleInspectGameObject(string jsonBody)
    {
        return await RunOnMainThread(() =>
        {
            string targetName = ExtractStringValue(jsonBody, "name");
            GameObject target = null;

            if (!string.IsNullOrEmpty(targetName))
            {
                target = GameObject.Find(targetName);
            }

            if (target == null)
            {
                return $"{{\"error\": \"GameObject not found with name '{targetName}'\"}}";
            }

            Vector3 pos = target.transform.position;
            Vector3 rot = target.transform.eulerAngles;
            Vector3 scl = target.transform.localScale;

            var comps = new List<string>();
            foreach (var c in target.GetComponents<Component>())
            {
                if (c != null) comps.Add($"\"{c.GetType().Name}\"");
            }

            return $@"{{
  ""name"": ""{EscapeJson(target.name)}"",
  ""instanceId"": {target.GetInstanceID()},
  ""active"": {target.activeInHierarchy.ToString().ToLower()},
  ""position"": [{pos.x}, {pos.y}, {pos.z}],
  ""rotation"": [{rot.x}, {rot.y}, {rot.z}],
  ""scale"": [{scl.x}, {scl.y}, {scl.z}],
  ""components"": [{string.Join(",", comps)}]
}}";
        });
    }

    private static async Task<string> HandleTransformGameObject(string jsonBody)
    {
        return await RunOnMainThread(() =>
        {
            string targetName = ExtractStringValue(jsonBody, "name");
            GameObject target = null;
            if (!string.IsNullOrEmpty(targetName))
            {
                target = GameObject.Find(targetName);
            }

            if (target == null)
            {
                return $"{{\"error\": \"GameObject not found with name '{targetName}'\"}}";
            }

            Undo.RecordObject(target.transform, "MCP Transform GameObject");

            Vector3? translate = ExtractVector3(jsonBody, "translate");
            if (translate.HasValue)
            {
                target.transform.position += translate.Value;
            }

            Vector3? position = ExtractVector3(jsonBody, "position");
            if (position.HasValue)
            {
                target.transform.position = position.Value;
            }

            Vector3? rotation = ExtractVector3(jsonBody, "rotation");
            if (rotation.HasValue)
            {
                target.transform.eulerAngles = rotation.Value;
            }

            Vector3? scale = ExtractVector3(jsonBody, "scale");
            if (scale.HasValue)
            {
                target.transform.localScale = scale.Value;
            }

            bool? active = ExtractBoolValue(jsonBody, "active");
            if (active.HasValue)
            {
                Undo.RecordObject(target, "MCP SetActive GameObject");
                target.SetActive(active.Value);
            }

            EditorUtility.SetDirty(target);
            Vector3 pos = target.transform.position;
            Vector3 rot = target.transform.eulerAngles;
            Vector3 scl = target.transform.localScale;

            return $@"{{
  ""success"": true,
  ""name"": ""{EscapeJson(target.name)}"",
  ""position"": [{pos.x}, {pos.y}, {pos.z}],
  ""rotation"": [{rot.x}, {rot.y}, {rot.z}],
  ""scale"": [{scl.x}, {scl.y}, {scl.z}]
}}";
        });
    }

    private static async Task<string> HandleDeleteGameObject(string jsonBody)
    {
        return await RunOnMainThread(() =>
        {
            string targetName = ExtractStringValue(jsonBody, "name");
            GameObject target = null;
            if (!string.IsNullOrEmpty(targetName))
            {
                target = GameObject.Find(targetName);
            }

            if (target == null)
            {
                return $"{{\"error\": \"GameObject not found with name '{targetName}'\"}}";
            }

            Undo.DestroyObjectImmediate(target);
            return $"{{\"success\": true, \"message\": \"Deleted '{EscapeJson(targetName)}'\"}}";
        });
    }

    private static async Task<string> HandleSaveScene()
    {
        return await RunOnMainThread(() =>
        {
            Scene activeScene = SceneManager.GetActiveScene();
            bool saved = UnityEditor.SceneManagement.EditorSceneManager.SaveScene(activeScene);
            return $"{{\"success\": {saved.ToString().ToLower()}, \"scene\": \"{EscapeJson(activeScene.name)}\"}}";
        });
    }

    private static async Task<string> HandleGetBattleStatus()
    {
        return await RunOnMainThread(() =>
        {
            var bm = BattleManager.Instance;
            if (bm == null) return "{\"error\": \"BattleManager not active\"}";
            return $@"{{
  ""bossName"": ""{EscapeJson(bm.bossName)}"",
  ""bossHp"": {bm.bossCurrentHp},
  ""bossMaxHp"": {bm.bossMaxHp},
  ""isBossDown"": {bm.isBossDown.ToString().ToLower()},
  ""isBossDead"": {bm.isBossDead.ToString().ToLower()},
  ""playerHp"": {bm.playerCurrentHp},
  ""playerMaxHp"": {bm.playerMaxHp},
  ""isDodging"": {bm.isDodging.ToString().ToLower()},
  ""isDefending"": {bm.isDefending.ToString().ToLower()},
  ""ultimateCharge"": {bm.ultimateCharge},
  ""level"": {bm.playerLevel},
  ""exp"": {bm.playerExp},
  ""timer"": {bm.battleTimeSeconds}
}}";
        });
    }

    private static async Task<string> HandleRefreshAssets()
    {
        return await RunOnMainThread(() =>
        {
            AssetDatabase.Refresh();
            return "{\"success\": true, \"message\": \"AssetDatabase refreshed\"}";
        });
    }
    #endregion

    #region Logging & Utilities
    private static void OnLogReceived(string condition, string stackTrace, LogType type)
    {
        lock (logLock)
        {
            consoleLogs.Add(new LogEntry
            {
                type = type.ToString(),
                message = condition,
                stackTrace = stackTrace,
                timestamp = DateTime.Now.ToString("HH:mm:ss.fff")
            });

            if (consoleLogs.Count > MAX_LOGS)
            {
                consoleLogs.RemoveAt(0);
            }
        }
    }

    private static string EscapeJson(string str)
    {
        if (string.IsNullOrEmpty(str)) return "";
        return str
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\r", "")
            .Replace("\n", "\\n")
            .Replace("\t", "\\t");
    }

    private static string ExtractStringValue(string json, string key)
    {
        if (string.IsNullOrEmpty(json)) return "";
        var match = Regex.Match(json, $"\"{key}\"\\s*:\\s*\"([^\"]*)\"", RegexOptions.IgnoreCase);
        return match.Success ? match.Groups[1].Value : "";
    }

    private static float? ExtractFloatValue(string json, string key)
    {
        if (string.IsNullOrEmpty(json)) return null;
        var match = Regex.Match(json, $"\"{key}\"\\s*:\\s*(-?[0-9]+(?:\\.[0-9]+)?)", RegexOptions.IgnoreCase);
        if (match.Success && float.TryParse(match.Groups[1].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out float val))
            return val;
        return null;
    }

    private static bool? ExtractBoolValue(string json, string key)
    {
        if (string.IsNullOrEmpty(json)) return null;
        var match = Regex.Match(json, $"\"{key}\"\\s*:\\s*(true|false)", RegexOptions.IgnoreCase);
        if (match.Success)
            return bool.Parse(match.Groups[1].Value);
        return null;
    }

    private static Vector3? ExtractVector3(string json, string key)
    {
        if (string.IsNullOrEmpty(json)) return null;
        var match = Regex.Match(json, $"\"{key}\"\\s*:\\s*\\[\\s*(-?[0-9]+(?:\\.[0-9]+)?)\\s*,\\s*(-?[0-9]+(?:\\.[0-9]+)?)\\s*,\\s*(-?[0-9]+(?:\\.[0-9]+)?)\\s*\\]", RegexOptions.IgnoreCase);
        if (match.Success)
        {
            float x = float.Parse(match.Groups[1].Value, CultureInfo.InvariantCulture);
            float y = float.Parse(match.Groups[2].Value, CultureInfo.InvariantCulture);
            float z = float.Parse(match.Groups[3].Value, CultureInfo.InvariantCulture);
            return new Vector3(x, y, z);
        }
        return null;
    }
    #endregion
}
#endif
