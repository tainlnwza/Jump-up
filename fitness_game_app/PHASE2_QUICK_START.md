# Phase 2 Quick Start Guide

## 🚀 เริ่มต้นอย่างรวดเร็ว (สำหรับคนรีบ)

หากคุณมีประสบการณ์ Blender และ Unity แล้ว ใช้ guide นี้เพื่อทำ Phase 2 ให้เร็วที่สุด

---

## ⏱️ Timeline Overview

**Total: 20-25 hours (expert) | 35-40 hours (intermediate)**

```
Day 1 (6-8 hours):
├─ Morning:   Blender rigging (2-3 hrs)
├─ Afternoon: Blender animations (4-5 hrs)
└─ Output:    MB_10001_animated.fbx

Day 2 (6-8 hours):
├─ Morning:   Unity setup + import (2-3 hrs)
├─ Afternoon: Unity scripts + VFX (4-5 hrs)
└─ Output:    Working Unity scene

Day 3 (4-6 hours):
├─ Morning:   Unity export + Flutter integration (3-4 hrs)
└─ Afternoon: Testing + bug fixes (1-2 hrs)
└─ Output:    Working AR game

Day 4-5 (4-8 hours):
└─ Polish, optimization, device testing
```

---

## 📋 Pre-flight Checklist

ก่อนเริ่ม ต้องมีครบ:

### Software
- [ ] Blender 4.0+ installed
- [ ] Unity Hub + Unity 2022.3 LTS installed
- [ ] Android Studio (for Android build)
- [ ] Xcode (for iOS build, Mac only)
- [ ] VS Code or IDE

### Files
- [ ] MB_10001.fbx (monster model)
- [ ] MB_T_20001.png (diffuse texture)
- [ ] MB_T_20001_S.png (specular)
- [ ] lvguang2.png (emission)

### Devices
- [ ] Physical iOS/Android device with ARCore/ARKit
- [ ] USB cable for testing
- [ ] Well-lit room with flat surface

### Knowledge
- [ ] Basic 3D modeling concepts
- [ ] Basic Unity navigation
- [ ] Basic Flutter/Dart

---

## ⚡ Fast Track: Blender (2-3 hours)

### Step 1: Setup (10 min)
```
1. Launch Blender
2. File → Import → FBX → D:\MB_10001\MB_10001.fbx
3. Delete default cube, keep light & camera
4. Switch to Shading workspace
5. Add Image Texture → MB_T_20001.png
```

### Step 2: Rigging (45-60 min)
```
1. Shift+A → Armature → Single Bone
2. Tab (Edit Mode)
3. Create bone hierarchy:
   Root → Spine_Lower → Spine_Upper → Neck → Head
   Root → Thigh_L/R → Shin_L/R → Foot_L/R
   Spine_Upper → Shoulder_L/R → UpperArm_L/R → ForeArm_L/R → Hand_L/R

Shortcuts:
- E: Extrude bone
- G: Move
- R: Rotate
- S: Scale
```

### Step 3: Skinning (15-20 min)
```
1. Select Monster mesh
2. Shift+Select Armature
3. Ctrl+P → With Automatic Weights
4. Tab → Pose Mode
5. Test: R to rotate bones
```

### Step 4: Animations (60-90 min)

**Workflow per animation:**
```
1. New Action: Click "+" in Action Editor
2. Set timeline length
3. Pose at keyframes
4. I: Insert keyframe
5. Playback to preview
6. Push down arrow (stash)
```

**Quick animation specs:**
```
Idle (90 frames):
- Frame 1: Default pose
- Frame 45: Breathe in (scale spine up 1.05x)
- Frame 90: Back to default

Attack (60 frames):
- Frame 1: Idle
- Frame 15: Wind-up (arm back)
- Frame 30: Strike (arm forward)
- Frame 60: Recover

Hit (20 frames):
- Frame 1: Normal
- Frame 10: Recoil back
- Frame 20: Recover

Stagger (120 frames, loop):
- Frame 30: On knees
- Frame 60-90-120: Sway left/center/right

Death (90 frames):
- Frame 1-20: Stagger
- Frame 40: Falling
- Frame 60: Hit ground
- Frame 90: Still
```

### Step 5: Export (5 min)
```
1. Select Armature + Mesh
2. File → Export → FBX
3. ✅ Selected Objects
4. ✅ Bake Animation
5. ✅ All Actions
6. Path: D:\MB_10001\MB_10001_animated.fbx
7. Export!
```

---

## ⚡ Fast Track: Unity (6-8 hours)

### Part A: Setup (90 min)

```bash
# 1. Create Project (10 min)
Unity Hub → New Project
Template: 3D (URP)
Name: FitnessGame_Unity
Location: D:\jump up\unity_project

# 2. Install Packages (15 min)
Window → Package Manager → "+" Add by name:
- com.unity.xr.arfoundation (5.1.0)
- com.unity.xr.arcore (5.1.0)
- com.unity.xr.arkit (5.1.0)

# 3. Configure Settings (20 min)
Edit → Project Settings → Player:

Android:
- Min API: 24
- Target API: 33
- IL2CPP + ARM64
- XR: ✅ ARCore

iOS:
- Min iOS: 12.0
- ARM64
- Camera Usage: "AR for fitness"
- XR: ✅ ARKit

# 4. Folder Structure (5 min)
Create folders:
Assets/Models/Monster/
Assets/Textures/Monster/
Assets/Scripts/
Assets/Prefabs/
Assets/VFX/
Assets/Scenes/
Assets/Materials/

# 5. Import Assets (10 min)
Copy:
MB_10001_animated.fbx → Assets/Models/Monster/
MB_T_20001.png, MB_T_20001_S.png, lvguang2.png → Assets/Textures/Monster/

# 6. Configure Model (15 min)
Select MB_10001_animated.fbx:
- Rig: Humanoid (or Generic)
- Animation: Loop Idle & Stagger only
- Apply

# 7. Create Material (10 min)
Assets/Materials/ → Create → Material
Name: MonsterMaterial
- Shader: URP/Lit
- Base Map: MB_T_20001.png
- Emission: ✅ lvguang2.png

# 8. Scene Setup (15 min)
File → New Scene → Basic
Delete Main Camera
Hierarchy → Right-click:
- XR → AR Session Origin
- XR → AR Session
Save: Assets/Scenes/GameScene.unity
```

### Part B: Scripts (90-120 min)

**Copy-paste ready scripts** from `UNITY_SETUP_GUIDE.md`:

```
1. Create: Assets/Scripts/MonsterController.cs
   → Copy code from guide (150 lines)

2. Create: Assets/Scripts/FlutterBridge.cs
   → Copy code from guide (120 lines)

3. Create: Assets/Scripts/ARPlacementManager.cs
   → Copy code from guide (100 lines)

4. Wait for compilation (no errors!)
```

### Part C: Animation Controller (30 min)

```
1. Create: Assets/Animations/MonsterAnimController
   (Animator Controller asset)

2. Open Animator window

3. Add 5 states:
   - Idle (default, orange)
   - Attack
   - Hit
   - Stagger
   - Death

4. Assign motions (drag animation clips)

5. Create transitions:
   Idle → Attack (Trigger: Attack)
   Attack → Idle (Exit Time)
   Idle → Hit (Trigger: Hit)
   Hit → Idle (Exit Time)
   Idle → Stagger (Trigger: Stagger)
   Stagger → Idle (Trigger: StaggerEnd)
   Any State → Death (Trigger: Death)

6. Create 5 Trigger parameters
```

### Part D: VFX (120-180 min)

**Quick VFX setup** (or skip and use simple ones):

```
For each VFX:
1. Hierarchy → Effects → Particle System
2. Configure modules (specs in UNITY_EXPORT_GUIDE.md)
3. Create Prefab
4. Delete from scene

Required VFX (priority order):
1. HitEffect (MUST HAVE - 20 min)
2. CriticalHitEffect (MUST HAVE - 15 min)
3. DeathEffect (MUST HAVE - 20 min)
4. ShieldEffect (nice to have - 25 min)
5. DodgeEffect (nice to have - 15 min)
6. HealEffect (nice to have - 20 min)
7. DamageNumber (optional - 30 min)

Minimum viable: Just do 1, 2, 3 (55 min)
```

### Part E: Prefab Assembly (20 min)

```
1. Drag MB_10001_animated to Scene
2. Add Components:
   - Animator (auto-added)
   - MonsterController script
   - Capsule Collider
3. Animator:
   - Controller: MonsterAnimController
4. MonsterController:
   - Hit Effect Prefab: drag VFX
   - Critical Hit Effect Prefab: drag VFX
   - Death Effect Prefab: drag VFX
5. Apply material to mesh
6. Drag to Prefabs/Monster_Prefab
7. Delete from scene
```

### Part F: AR Setup (30 min)

```
1. Select AR Session Origin
2. Add Component → AR Plane Manager
3. Add Component → AR Placement Manager (your script)
4. AR Placement Manager:
   - Monster Prefab: drag Monster_Prefab
   - Distance From Camera: 2

5. Create GameObject → Empty
   Name: GameManager
   Add Component → Flutter Bridge (your script)

6. Save scene
```

---

## ⚡ Fast Track: Flutter Integration (3-4 hours)

### Step 1: Export Unity (30-45 min)

```bash
# Android
File → Build Settings
Platform: Android
✅ Export Project
Export to: D:\jump up\unity_project\Builds\Android
Wait...

# iOS
File → Build Settings
Platform: iOS
Export to: D:\jump up\unity_project\Builds\iOS
Wait...
```

### Step 2: Add Package (5 min)

```yaml
# pubspec.yaml
dependencies:
  flutter_unity_widget: ^2022.2.0
```

```bash
flutter pub get
```

### Step 3: Copy Integration Code (60 min)

**Create 2 new files** from `UNITY_EXPORT_GUIDE.md`:

```
1. lib/services/unity_service.dart
   → Copy full code (150 lines)

2. lib/screens/game/ar_boss_battle_screen.dart
   → Copy full code (300 lines)

3. Update main.dart:
   Add route to ARBossBattleScreen
```

### Step 4: Wire MediaPipe (45 min)

In `ar_boss_battle_screen.dart`, implement:

```dart
void _startPoseDetection() {
  _mediaPipe.startDetection((pose) {
    if (pose == PoseType.punch) {
      _performAction(PoseType.punch);
    }
    // ... other poses
  });
}
```

### Step 5: Test Build (30 min)

```bash
# Android
flutter build apk --debug

# Install on device
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or
flutter run --release
```

---

## ✅ Testing Checklist (1-2 hours)

### Unity Editor Tests (30 min)
- [ ] Play mode: Monster animates
- [ ] Console: No errors
- [ ] Scripts compile
- [ ] VFX visible in Scene view

### Device Tests - Critical Path (30 min)
- [ ] App installs
- [ ] AR camera opens
- [ ] Point at floor → plane detected
- [ ] Monster appears automatically
- [ ] Monster faces camera
- [ ] Tap debug buttons → animations play
- [ ] VFX play

### Device Tests - Full Flow (30 min)
- [ ] HP bars update
- [ ] Hit effects spawn
- [ ] Critical hits look different
- [ ] Monster staggers at 25% HP
- [ ] Death animation plays
- [ ] No crashes
- [ ] FPS check (30+)

---

## 🆘 Quick Troubleshooting

### Blender: "Mesh doesn't move with bones"
```
Select Mesh → Shift+Select Armature → Ctrl+P → With Automatic Weights
```

### Unity: "AR doesn't work in Editor"
```
Normal - AR only works on device. Test with scripts instead.
```

### Unity: "Can't find monster animations"
```
Select FBX → Inspector → Animation tab → Check "Import Animation"
Click Apply
```

### Flutter: "Unity widget is black screen"
```
1. Check Unity export completed
2. Check UnityService.setController() called
3. Check device supports AR (ARCore/ARKit)
4. Grant camera permissions
```

### Device: "Monster doesn't appear"
```
1. Point camera at flat, well-lit surface
2. Move device slowly
3. Wait 2-3 seconds for plane detection
4. Check Unity logs (adb logcat | grep Unity)
```

### Device: "App crashes on AR open"
```
1. Check AR permissions granted
2. Check device supports ARCore/ARKit
3. Check Unity build settings correct
4. Try clean build: flutter clean
```

---

## 📊 Progress Tracking

Use this to track your work:

### Blender Checklist
- [ ] Model imported
- [ ] Armature created (13-15 bones)
- [ ] Mesh skinned
- [ ] Idle animation (90 frames)
- [ ] Attack animation (60 frames)
- [ ] Hit animation (20 frames)
- [ ] Stagger animation (120 frames)
- [ ] Death animation (90 frames)
- [ ] Exported: MB_10001_animated.fbx

### Unity Checklist
- [ ] Project created (URP)
- [ ] AR packages installed
- [ ] Model imported
- [ ] Material created and applied
- [ ] Animator Controller created
- [ ] 5 animation states setup
- [ ] MonsterController.cs written
- [ ] FlutterBridge.cs written
- [ ] ARPlacementManager.cs written
- [ ] 3 VFX created (minimum)
- [ ] Monster prefab assembled
- [ ] AR scene setup
- [ ] Exported for Android/iOS

### Flutter Checklist
- [ ] flutter_unity_widget added
- [ ] UnityService created
- [ ] ARBossBattleScreen created
- [ ] MediaPipe integrated
- [ ] Routes updated
- [ ] Builds successfully
- [ ] Tested on device

---

## 🎯 Minimum Viable Phase 2

หากเวลาจำกัด ทำแค่นี้ก็พอ:

### Must Have (15-20 hours)
✅ Blender: Rigged monster + Idle + Attack + Death animations only
✅ Unity: Basic setup + scripts + 1 VFX (hit effect)
✅ Flutter: Basic integration + AR placement
✅ Works on one platform (Android OR iOS)

### Nice to Have (add later)
- All 5 animations
- All 7 VFX
- Cross-platform support
- Polish & optimization

---

## 🚀 Ready to Start!

**เริ่มเลยตอนนี้:**

1. Open `docs/BLENDER_RIGGING_GUIDE.md`
2. Follow step-by-step
3. Move to next guide when done

**เจอปัญหา:**
- Check PHASE2_TROUBLESHOOTING.md
- Ask in Discord/Forum
- Google: "Unity AR Foundation [your issue]"

**Good luck! 🎮✨**
