using UnityEngine;
using System;
using System.Runtime.InteropServices;

public class FlutterBridge : MonoBehaviour
{
    private static FlutterBridge instance;
    private MonsterController monster;
    private ARPlacementManager arPlacement;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        arPlacement = FindObjectOfType<ARPlacementManager>();
        monster = FindObjectOfType<MonsterController>();
        Debug.Log("<color=#4CAF50>[FlutterBridge] Initialized.</color>");
    }

    // Called from Flutter (message comes as JSON string)
    public void OnFlutterMessage(string jsonMessage)
    {
        try
        {
            Debug.Log($"[FlutterBridge] Received from Flutter: {jsonMessage}");
            FlutterMessage msg = JsonUtility.FromJson<FlutterMessage>(jsonMessage);
            HandleMessage(msg);
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] Failed to parse message: {e.Message}");
        }
    }

    void HandleMessage(FlutterMessage msg)
    {
        switch (msg.type)
        {
            case "START_BATTLE":
                StartBattle(msg.data);
                break;

            case "PLAYER_ACTION":
                HandlePlayerAction(msg.data);
                break;

            case "BOSS_ATTACK":
                BossAttack();
                break;

            case "BATTLE_END":
                EndBattle(msg.data);
                break;

            case "RESET_GAME":
                ResetGame();
                break;

            default:
                Debug.LogWarning($"[FlutterBridge] Unknown message type: {msg.type}");
                break;
        }
    }

    void StartBattle(string data)
    {
        Debug.Log("[FlutterBridge] Starting battle");
        monster = FindObjectOfType<MonsterController>();

        if (monster != null)
        {
            SendMessage("BATTLE_STARTED", "{}");
        }
        else
        {
            Debug.LogWarning("[FlutterBridge] Monster not found in scene yet!");
            SendMessage("BATTLE_ERROR", "{\"error\":\"Monster not found\"}");
        }
    }

    void HandlePlayerAction(string data)
    {
        try
        {
            PlayerAction action = JsonUtility.FromJson<PlayerAction>(data);
            Debug.Log($"[FlutterBridge] MediaPipe / Flutter Player Action: {action.action}");

            string act = action.action.ToUpper();
            if (act == "PUNCH")
            {
                BattleManager.Instance?.ExecuteAction(PlayerActionType.Punch);
            }
            else if (act == "UPPERCUT")
            {
                BattleManager.Instance?.ExecuteAction(PlayerActionType.Uppercut);
            }
            else if (act == "SQUAT")
            {
                BattleManager.Instance?.ExecuteAction(PlayerActionType.Squat);
            }
            else if (act == "PLANK")
            {
                BattleManager.Instance?.ExecuteAction(PlayerActionType.Plank);
            }
            else if (act == "HIGH_KNEE" || act == "HIGHKNEE")
            {
                BattleManager.Instance?.ExecuteAction(PlayerActionType.HighKnee);
            }
            else if (act == "ULTIMATE")
            {
                BattleManager.Instance?.ExecuteAction(PlayerActionType.Ultimate);
            }
            else
            {
                // Fallback direct damage
                monster?.TakeDamage(action.damage, false);
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] Error handling player action: {e.Message}");
        }
    }

    void BossAttack()
    {
        if (monster != null)
        {
            monster.PlayAttackAnimation();
        }
    }

    void EndBattle(string data)
    {
        Debug.Log($"[FlutterBridge] Battle ended: {data}");
    }

    void ResetGame()
    {
        Debug.Log("[FlutterBridge] Resetting game");
        UnityEngine.SceneManagement.SceneManager.LoadScene(
            UnityEngine.SceneManagement.SceneManager.GetActiveScene().name
        );
    }

    // Send message back to Flutter
    public static void SendMessage(string messageType, string data)
    {
        string fullMessage = $"{{\"type\":\"{messageType}\",\"data\":{data}}}";
        Debug.Log($"[FlutterBridge] Sending to Flutter: {fullMessage}");

#if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
            activity.Call("onUnityMessage", fullMessage);
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] Android send error: {e.Message}");
        }
#elif UNITY_IOS && !UNITY_EDITOR
        try
        {
            NativeAPI.SendMessageToFlutter(fullMessage);
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] iOS send error: {e.Message}");
        }
#else
        // In Editor, just log
        Debug.Log($"[FlutterBridge EDITOR STUB] Message to Flutter: {fullMessage}");
#endif
    }

    [System.Serializable]
    public class FlutterMessage
    {
        public string type;
        public string data;
    }

    [System.Serializable]
    public class PlayerAction
    {
        public string action;
        public int damage;
        public float confidence;
    }
}
