// Unity C# Script: FlutterBridge.cs
// Location: unity_project/Assets/Scripts/FlutterBridge.cs

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
        Debug.Log("[FlutterBridge] Initialized");
    }

    // Called from Flutter (message comes as JSON string)
    public void OnFlutterMessage(string jsonMessage)
    {
        try
        {
            Debug.Log($"[FlutterBridge] Received: {jsonMessage}");
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

        // Find monster (should already be placed via AR)
        monster = FindObjectOfType<MonsterController>();

        if (monster != null)
        {
            SendMessage("BATTLE_STARTED", "{}");
        }
        else
        {
            Debug.LogError("[FlutterBridge] Monster not found!");
            SendMessage("BATTLE_ERROR", "{\"error\":\"Monster not found\"}");
        }
    }

    void HandlePlayerAction(string data)
    {
        if (monster == null)
        {
            Debug.LogWarning("[FlutterBridge] No monster to attack");
            return;
        }

        try
        {
            PlayerAction action = JsonUtility.FromJson<PlayerAction>(data);
            Debug.Log($"[FlutterBridge] Player action: {action.action}, damage: {action.damage}");

            switch (action.action)
            {
                case "PUNCH":
                    monster.TakeDamage(action.damage, false);
                    break;

                case "UPPERCUT":
                    monster.TakeDamage(action.damage, true); // critical hit
                    break;

                case "SQUAT":
                case "PLANK":
                case "HIGH_KNEE":
                    // Defensive actions handled by Flutter
                    Debug.Log($"[FlutterBridge] Defensive action: {action.action}");
                    break;

                default:
                    Debug.LogWarning($"[FlutterBridge] Unknown action: {action.action}");
                    break;
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] Error handling player action: {e.Message}");
        }
    }

    void BossAttack()
    {
        if (monster != null && !monster.isDead)
        {
            monster.PlayAttackAnimation();
            Debug.Log("[FlutterBridge] Boss attacking");
        }
    }

    void EndBattle(string data)
    {
        Debug.Log("[FlutterBridge] Battle ended");

        if (monster != null)
        {
            Destroy(monster.gameObject);
            monster = null;
        }

        SendMessage("BATTLE_ENDED", "{}");
    }

    void ResetGame()
    {
        Debug.Log("[FlutterBridge] Resetting game");

        if (monster != null)
        {
            Destroy(monster.gameObject);
            monster = null;
        }

        if (arPlacement != null)
        {
            arPlacement.ResetPlacement();
        }

        SendMessage("GAME_RESET", "{}");
    }

    // Send message to Flutter
    public static void SendMessage(string messageType, string data)
    {
        string json = $"{{\"type\":\"{messageType}\",\"data\":{data}}}";

        Debug.Log($"[FlutterBridge] Sending to Flutter: {json}");

        #if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            using (AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            {
                using (AndroidJavaObject currentActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
                {
                    currentActivity.Call("onUnityMessage", json);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] Android message failed: {e.Message}");
        }
        #elif UNITY_IOS && !UNITY_EDITOR
        try
        {
            _SendMessageToFlutter(json);
        }
        catch (Exception e)
        {
            Debug.LogError($"[FlutterBridge] iOS message failed: {e.Message}");
        }
        #else
        // Editor: Log only
        Debug.Log($"[FlutterBridge → Flutter] {json}");
        #endif
    }

    #if UNITY_IOS && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void _SendMessageToFlutter(string message);
    #endif
}

[Serializable]
public class FlutterMessage
{
    public string type;
    public string data;
}

[Serializable]
public class PlayerAction
{
    public string action;
    public int damage;
}

[Serializable]
public class BattleData
{
    public string bossId;
    public int difficulty;
}
