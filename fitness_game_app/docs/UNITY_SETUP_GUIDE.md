# Unity AR Game Setup Guide

## 🎯 Objective
Create a Unity project with AR Foundation, import the animated monster, and build the game logic.

**Time Required:** 8-12 hours total
- Unity Setup: 2-3 hours
- Monster Integration: 2-3 hours
- Game Logic: 4-6 hours

---

## 📋 Prerequisites

### Software
- **Unity Hub** (Download: https://unity.com/download)
- **Unity 2022.3 LTS** (install via Hub)
- **Android Build Support** module (for Android)
- **iOS Build Support** module (for iOS)
- Visual Studio or VS Code (for scripting)

### Files from Blender
- `MB_10001_animated.fbx` (from Blender guide)
- `MB_T_20001.png` (diffuse texture)
- `MB_T_20001_S.png` (specular texture)
- `lvguang2.png` (emission texture)

---

## 🚀 Part 1: Unity Project Setup (2-3 hours)

### Step 1: Create New Unity Project

1. **Open Unity Hub**
   - Click "New Project"
   - Select Unity 2022.3 LTS
   - Template: **3D (URP)** (Universal Render Pipeline)
   - Project Name: `FitnessGame_Unity`
   - Location: `D:\jump up\unity_project`
   - Click "Create Project"

2. **Wait for project to initialize** (3-5 minutes)

### Step 2: Install Required Packages

1. **Open Package Manager**
   ```
   Window → Package Manager
   ```

2. **Install AR Foundation**
   ```
   - Click "+" → Add package by name
   - Name: com.unity.xr.arfoundation
   - Version: 5.1.0
   - Click "Add"
   ```

3. **Install ARCore XR Plugin (Android)**
   ```
   - "+" → Add package by name
   - Name: com.unity.xr.arcore
   - Version: 5.1.0
   - Click "Add"
   ```

4. **Install ARKit XR Plugin (iOS)**
   ```
   - "+" → Add package by name
   - Name: com.unity.xr.arkit
   - Version: 5.1.0
   - Click "Add"
   ```

5. **Verify Installation**
   ```
   - All packages should show "Up to date" in Package Manager
   ```

### Step 3: Configure Project Settings

1. **Player Settings**
   ```
   Edit → Project Settings → Player
   ```

   **For Android:**
   ```
   - Switch platform: Android icon
   - Other Settings:
     - Minimum API Level: Android 7.0 (API 24)
     - Target API Level: Automatic (highest installed)
     - Scripting Backend: IL2CPP
     - ARM64: ✅ Checked
   - XR Plug-in Management:
     - ✅ ARCore
   ```

   **For iOS:**
   ```
   - Switch platform: iOS icon
   - Other Settings:
     - Target minimum iOS Version: 12.0
     - Architecture: ARM64
     - Camera Usage Description: "AR for fitness game"
   - XR Plug-in Management:
     - ✅ ARKit
   ```

2. **Graphics Settings**
   ```
   Edit → Project Settings → Graphics
   - Scriptable Render Pipeline Settings: 
     - Should show URP asset (auto-assigned)
   ```

3. **Quality Settings**
   ```
   Edit → Project Settings → Quality
   - Levels: Remove all except "Medium"
   - Medium settings:
     - Shadows: Soft Shadows
     - Shadow Resolution: Medium
     - Shadow Distance: 20
     - Texture Quality: Full Res
   ```

### Step 4: Create Folder Structure

```
Project/
└── Assets/
    ├── Models/
    │   └── Monster/
    ├── Textures/
    │   └── Monster/
    ├── Scripts/
    ├── Prefabs/
    ├── VFX/
    ├── Scenes/
    └── Materials/
```

**In Unity:**
```
Right-click in Project window → Create → Folder
Name folders as above
```

---

## 🎨 Part 2: Import Monster (1-2 hours)

### Step 1: Import Model & Textures

1. **Copy Files**
   ```
   From: D:\MB_10001\
   To: D:\jump up\unity_project\Assets\Models\Monster\
   
   Files:
   - MB_10001_animated.fbx
   
   From: D:\MB_10001\
   To: D:\jump up\unity_project\Assets\Textures\Monster\
   
   Files:
   - MB_T_20001.png
   - MB_T_20001_S.png
   - lvguang2.png
   ```

2. **Unity will auto-import** (wait for progress bar)

### Step 2: Configure Model Import Settings

1. **Select** `MB_10001_animated.fbx` in Project window

2. **Inspector → Model tab:**
   ```
   - Scale Factor: 1
   - ✅ Import BlendShapes
   - ✅ Import Visibility
   - ✅ Import Cameras: ❌ Unchecked
   - ✅ Import Lights: ❌ Unchecked
   ```

3. **Inspector → Rig tab:**
   ```
   - Animation Type: Humanoid (or Generic if Humanoid fails)
   - Avatar Definition: Create From This Model
   - Click "Apply"
   ```

4. **Inspector → Animation tab:**
   ```
   Should show 5 clips:
   - Monster_Idle
   - Monster_Attack
   - Monster_Hit
   - Monster_Stagger
   - Monster_Death
   
   For each animation:
   - Select it
   - Loop Time: 
     ✅ Idle (checked)
     ✅ Stagger (checked)
     ❌ Others (unchecked)
   - Click "Apply"
   ```

### Step 3: Create Material

1. **Create Material**
   ```
   Assets/Materials/ → Right-click → Create → Material
   Name: "MonsterMaterial"
   ```

2. **Configure Material**
   ```
   - Shader: Universal Render Pipeline/Lit
   - Surface Type: Opaque
   - Base Map: Drag MB_T_20001.png
   - Metallic: 0
   - Smoothness: 0.3
   - Emission: ✅ Check
   - Emission Map: Drag lvguang2.png
   - Emission Color: Slight yellow (intensity: 1)
   ```

3. **Apply to Model**
   ```
   - Drag MB_10001_animated into Scene (creates instance)
   - Expand in Hierarchy → find mesh child
   - Drag MonsterMaterial onto mesh in Hierarchy
   - Monster should now show textures
   ```

### Step 4: Create Monster Prefab

1. **Setup Monster GameObject**
   ```
   - Select monster in Hierarchy
   - Reset Transform (Inspector → Transform → ⚙️ → Reset)
   - Position: (0, 0, 0)
   - Scale: (1, 1, 1) or adjust if too big/small
   ```

2. **Add Components**
   ```
   - Click "Add Component"
   - Animator (should already have)
   - Add Component → Capsule Collider (for hit detection)
     - Radius: Adjust to monster width
     - Height: Adjust to monster height
   ```

3. **Create Prefab**
   ```
   - Drag monster from Hierarchy to Assets/Prefabs/
   - Name: "Monster_Prefab"
   - Delete instance from Scene
   ```

---

## 🎮 Part 3: Animation Controller (1 hour)

### Step 1: Create Animator Controller

1. **Create Controller**
   ```
   Assets/ → Right-click → Create → Animator Controller
   Name: "MonsterAnimController"
   Location: Assets/Animations/ (create folder if needed)
   ```

2. **Open Animator Window**
   ```
   Window → Animation → Animator
   Double-click MonsterAnimController
   ```

### Step 2: Add Animation States

1. **Add States**
   ```
   - Right-click in Animator → Create State → Empty
   - Rename to: "Idle"
   - Motion: Drag Monster_Idle clip
   - Right-click "Idle" → Set as Layer Default State (turns orange)
   
   Repeat for:
   - Attack (Monster_Attack)
   - Hit (Monster_Hit)
   - Stagger (Monster_Stagger)
   - Death (Monster_Death)
   ```

### Step 3: Create Transitions

**Idle → Attack**
```
- Right-click Idle → Make Transition → Click Attack
- Select transition arrow
- Inspector:
  - Has Exit Time: ❌ Unchecked
  - Transition Duration: 0.1
- Click "+" → Add Condition
  - Parameter: Attack (create new Trigger)
```

**Attack → Idle**
```
- Right-click Attack → Make Transition → Click Idle
- Has Exit Time: ✅ Checked (auto returns after animation)
- Transition Duration: 0.2
```

**Idle → Hit**
```
- Idle → Hit transition
- Condition: Hit (Trigger)
- Has Exit Time: ❌
- Transition Duration: 0.05
```

**Hit → Idle**
```
- Hit → Idle
- Has Exit Time: ✅
```

**Idle → Stagger**
```
- Idle → Stagger
- Condition: Stagger (Trigger)
- Has Exit Time: ❌
```

**Stagger → Idle**
```
- Stagger → Idle
- Condition: StaggerEnd (Trigger)
- Has Exit Time: ❌
```

**Any State → Death**
```
- Right-click "Any State" → Make Transition → Death
- Condition: Death (Trigger)
- Has Exit Time: ❌
- Cannot Transition To Self: ✅
```

### Step 4: Configure Parameters

```
In Animator window → Parameters tab:
- Attack (Trigger)
- Hit (Trigger)
- Stagger (Trigger)
- StaggerEnd (Trigger)
- Death (Trigger)
```

### Step 5: Assign Controller to Prefab

```
- Open Monster_Prefab
- Select Animator component
- Controller: Drag MonsterAnimController
- Save Prefab
```

---

## 🌍 Part 4: AR Setup (2 hours)

### Step 1: Create AR Scene

1. **New Scene**
   ```
   File → New Scene → Basic (Built-in)
   Save As: Assets/Scenes/GameScene.unity
   ```

2. **Delete Default Camera** (we'll use AR Camera)

### Step 2: Setup AR Session Origin

1. **Create AR Session Origin**
   ```
   Hierarchy → Right-click → XR → AR Session Origin
   ```

2. **Configure AR Session Origin**
   ```
   - Inspector:
     - AR Session Origin component (auto-added)
     - Should have child: "AR Camera"
   ```

3. **AR Camera Settings**
   ```
   - Select "AR Camera" child
   - Tag: MainCamera
   - Clear Flags: Solid Color
   - Background: Black (or transparent)
   ```

### Step 3: Add AR Session

```
Hierarchy → Right-click → XR → AR Session
(This manages AR lifecycle)
```

### Step 4: Add AR Plane Manager

1. **Add to AR Session Origin**
   ```
   - Select AR Session Origin
   - Add Component → AR Plane Manager
   ```

2. **Create Plane Visualization Prefab** (optional, for debugging)
   ```
   - GameObject → 3D Object → Plane
   - Scale: (0.1, 0.1, 0.1)
   - Add Material: Semi-transparent blue
   - Create Prefab: "AR_Plane_Prefab"
   - Delete from scene
   ```

3. **Configure AR Plane Manager**
   ```
   - Detection Mode: Horizontal
   - Plane Prefab: Drag AR_Plane_Prefab (optional)
   ```

### Step 5: Create Monster Spawn Point

1. **Create Empty GameObject**
   ```
   Hierarchy → Create Empty
   Name: "MonsterSpawnPoint"
   Position: (0, 0, 2) (2 meters in front of camera)
   ```

---

## 💻 Part 5: Game Scripts (4-6 hours)

### Script 1: MonsterController.cs

```csharp
// Save to: Assets/Scripts/MonsterController.cs
using UnityEngine;

public class MonsterController : MonoBehaviour
{
    [Header("Components")]
    private Animator animator;
    
    [Header("Stats")]
    public int maxHealth = 200;
    public int currentHealth;
    public bool isDead = false;
    public bool isStaggered = false;
    
    [Header("VFX")]
    public GameObject hitEffectPrefab;
    public GameObject criticalHitEffectPrefab;
    public GameObject deathEffectPrefab;
    
    void Start()
    {
        animator = GetComponent<Animator>();
        currentHealth = maxHealth;
        
        // Notify Flutter that Unity is ready
        SendMessageToFlutter("UNITY_READY", "{}");
    }
    
    // Called from Flutter
    public void TakeDamage(int damage, bool isCritical = false)
    {
        if (isDead) return;
        
        currentHealth -= damage;
        currentHealth = Mathf.Max(0, currentHealth);
        
        // Play hit animation
        if (!isStaggered)
        {
            animator.SetTrigger("Hit");
        }
        
        // Spawn VFX
        GameObject effect = isCritical ? criticalHitEffectPrefab : hitEffectPrefab;
        if (effect != null)
        {
            Instantiate(effect, transform.position + Vector3.up * 1.5f, Quaternion.identity);
        }
        
        // Check for stagger (25% health)
        if (currentHealth <= maxHealth * 0.25f && !isStaggered && !isDead)
        {
            EnterStagger();
        }
        
        // Check for death
        if (currentHealth <= 0)
        {
            Die();
        }
        
        // Notify Flutter
        SendMessageToFlutter("DAMAGE_DEALT", $"{{\"damage\":{damage},\"currentHp\":{currentHealth}}}");
    }
    
    public void PlayAttackAnimation()
    {
        if (isDead || isStaggered) return;
        animator.SetTrigger("Attack");
    }
    
    void EnterStagger()
    {
        isStaggered = true;
        animator.SetTrigger("Stagger");
        SendMessageToFlutter("MONSTER_STAGGERED", "{}");
        
        // Auto-recover after 10 seconds
        Invoke("ExitStagger", 10f);
    }
    
    void ExitStagger()
    {
        isStaggered = false;
        animator.SetTrigger("StaggerEnd");
        SendMessageToFlutter("MONSTER_RECOVERED", "{}");
    }
    
    void Die()
    {
        isDead = true;
        animator.SetTrigger("Death");
        
        // Spawn death effect
        if (deathEffectPrefab != null)
        {
            Instantiate(deathEffectPrefab, transform.position, Quaternion.identity);
        }
        
        SendMessageToFlutter("MONSTER_DEFEATED", "{}");
        
        // Destroy after animation
        Destroy(gameObject, 3f);
    }
    
    void SendMessageToFlutter(string messageType, string data)
    {
        // Flutter communication (implemented in FlutterBridge)
        FlutterBridge.SendMessage(messageType, data);
    }
}
```

### Script 2: FlutterBridge.cs

```csharp
// Save to: Assets/Scripts/FlutterBridge.cs
using UnityEngine;
using System;
using System.Collections.Generic;

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
        // Find managers
        arPlacement = FindObjectOfType<ARPlacementManager>();
    }
    
    // Called from Flutter (message comes as JSON string)
    public void OnFlutterMessage(string jsonMessage)
    {
        try
        {
            FlutterMessage msg = JsonUtility.FromJson<FlutterMessage>(jsonMessage);
            HandleMessage(msg);
        }
        catch (Exception e)
        {
            Debug.LogError($"Failed to parse Flutter message: {e.Message}");
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
                EndBattle();
                break;
                
            default:
                Debug.LogWarning($"Unknown message type: {msg.type}");
                break;
        }
    }
    
    void StartBattle(string data)
    {
        // Monster should already be placed via AR
        monster = FindObjectOfType<MonsterController>();
        if (monster != null)
        {
            SendMessage("BATTLE_STARTED", "{}");
        }
    }
    
    void HandlePlayerAction(string data)
    {
        if (monster == null) return;
        
        PlayerAction action = JsonUtility.FromJson<PlayerAction>(data);
        
        switch (action.action)
        {
            case "PUNCH":
                monster.TakeDamage(action.damage, false);
                break;
                
            case "UPPERCUT":
                monster.TakeDamage(action.damage, true); // critical
                break;
                
            case "SQUAT":
            case "PLANK":
            case "HIGH_KNEE":
                // Defensive actions, no damage to monster
                break;
        }
    }
    
    void BossAttack()
    {
        if (monster != null)
        {
            monster.PlayAttackAnimation();
        }
    }
    
    void EndBattle()
    {
        if (monster != null)
        {
            Destroy(monster.gameObject);
        }
    }
    
    // Send message to Flutter
    public static void SendMessage(string messageType, string data)
    {
        string json = $"{{\"type\":\"{messageType}\",\"data\":{data}}}";
        
        #if UNITY_ANDROID && !UNITY_EDITOR
        // Android: Use UnityPlayer
        using (AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
        {
            using (AndroidJavaObject currentActivity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
            {
                currentActivity.Call("onUnityMessage", json);
            }
        }
        #elif UNITY_IOS && !UNITY_EDITOR
        // iOS: Use extern C function
        _SendMessageToFlutter(json);
        #else
        // Editor: Log only
        Debug.Log($"[Unity→Flutter] {json}");
        #endif
    }
    
    #if UNITY_IOS && !UNITY_EDITOR
    [System.Runtime.InteropServices.DllImport("__Internal")]
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
```

### Script 3: ARPlacementManager.cs

```csharp
// Save to: Assets/Scripts/ARPlacementManager.cs
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;

public class ARPlacementManager : MonoBehaviour
{
    [Header("AR Components")]
    private ARRaycastManager raycastManager;
    private ARPlaneManager planeManager;
    
    [Header("Monster")]
    public GameObject monsterPrefab;
    private GameObject spawnedMonster;
    private bool monsterPlaced = false;
    
    [Header("Placement")]
    public float distanceFromCamera = 2f;
    
    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    
    void Start()
    {
        raycastManager = GetComponent<ARRaycastManager>();
        planeManager = GetComponent<ARPlaneManager>();
        
        if (monsterPrefab == null)
        {
            Debug.LogError("Monster prefab not assigned!");
        }
    }
    
    void Update()
    {
        if (!monsterPlaced)
        {
            DetectPlaneAndPlace();
        }
    }
    
    void DetectPlaneAndPlace()
    {
        // Raycast from center of screen
        Vector2 screenCenter = new Vector2(Screen.width / 2, Screen.height / 2);
        
        if (raycastManager.Raycast(screenCenter, hits, TrackableType.PlaneWithinPolygon))
        {
            Pose hitPose = hits[0].pose;
            
            // Notify Flutter that plane is detected
            FlutterBridge.SendMessage("AR_PLANE_DETECTED", "{\"canPlace\":true}");
            
            // Auto-place monster after 1 second of stable plane
            if (!monsterPlaced)
            {
                Invoke("PlaceMonster", 1f);
            }
        }
    }
    
    void PlaceMonster()
    {
        if (monsterPlaced) return;
        
        // Calculate position in front of camera
        Camera arCamera = Camera.main;
        Vector3 spawnPosition = arCamera.transform.position + arCamera.transform.forward * distanceFromCamera;
        spawnPosition.y = 0; // Ground level
        
        // Spawn monster
        spawnedMonster = Instantiate(monsterPrefab, spawnPosition, Quaternion.identity);
        
        // Rotate to face camera
        Vector3 lookDirection = arCamera.transform.position - spawnedMonster.transform.position;
        lookDirection.y = 0;
        spawnedMonster.transform.rotation = Quaternion.LookRotation(lookDirection);
        
        monsterPlaced = true;
        
        // Disable plane visualization
        planeManager.enabled = false;
        foreach (var plane in planeManager.trackables)
        {
            plane.gameObject.SetActive(false);
        }
        
        // Notify Flutter
        FlutterBridge.SendMessage("MONSTER_PLACED", $"{{\"position\":[{spawnPosition.x},{spawnPosition.y},{spawnPosition.z}]}}");
    }
    
    public void ResetPlacement()
    {
        if (spawnedMonster != null)
        {
            Destroy(spawnedMonster);
        }
        monsterPlaced = false;
        planeManager.enabled = true;
    }
}
```

---

## 🎨 Part 6: VFX Creation (2-3 hours)

Will continue in next message...

*Guide continues with VFX particle systems, testing, and export steps*

---

## ✅ Quick Verification

At this point you should have:
- [ ] Unity project opens without errors
- [ ] Monster model imported with 5 animations
- [ ] Animator controller with all states
- [ ] AR Session Origin in scene
- [ ] 3 C# scripts created
- [ ] Monster prefab with controller assigned

**Next:** Create VFX particle systems and test in Unity Editor

---

**🎯 Once Unity side is complete, move to `UNITY_EXPORT_GUIDE.md` for Flutter integration!**
