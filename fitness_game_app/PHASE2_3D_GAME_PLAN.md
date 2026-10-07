# Phase 2: 3D AR Game System Implementation Plan

## 📋 Overview

Transform the 2D placeholder boss battle into a full 3D AR experience using Unity embedded in Flutter.

**Technology Stack:**
- Flutter (UI, navigation, database)
- Unity 2022.3 LTS (3D rendering, AR, animations)
- AR Foundation (cross-platform AR)
- Blender 4.0+ (monster rigging & animation)

## 🎯 Implementation Phases

### Phase 2A: Asset Preparation (External Tools)
1. **Blender: Monster Rigging** (2-3 hours)
2. **Blender: Animation Creation** (4-6 hours)
3. **Unity: Project Setup** (1-2 hours)
4. **Unity: AR Foundation Setup** (2-3 hours)
5. **Unity: Monster Integration** (1-2 hours)

### Phase 2B: Unity Game Logic (Unity)
6. **Monster Controller** (2-3 hours)
7. **Animation State Machine** (2-3 hours)
8. **VFX System** (3-4 hours)
9. **Damage System** (2-3 hours)
10. **AR Placement** (2-3 hours)

### Phase 2C: Flutter Integration (Flutter)
11. **Flutter-Unity Bridge** (3-4 hours)
12. **Updated Boss Battle Screen** (2-3 hours)
13. **Communication Protocol** (2-3 hours)
14. **Testing & Optimization** (4-6 hours)

**Total Estimated Time:** 30-40 hours

---

## 📐 System Architecture

```
┌─────────────────────────────────────────┐
│           Flutter Layer                  │
│  - UI (HP bars, buttons, HUD)           │
│  - MediaPipe (pose detection)           │
│  - Database (save sessions)             │
│  - Navigation                            │
└──────────────┬──────────────────────────┘
               │ Message Channel
               │ (JSON commands)
┌──────────────┴──────────────────────────┐
│           Unity Layer                    │
│  - 3D Monster rendering                 │
│  - AR Foundation (plane detection)      │
│  - Animation state machine              │
│  - VFX system (hit, heal, shield)       │
│  - Damage numbers                        │
└─────────────────────────────────────────┘
```

---

## 🎨 Monster Animations

### Required Animations (5 total)

1. **Idle** (Loop, 3-5 seconds)
   - Breathing motion
   - Subtle head movement
   - Weight shift

2. **Attack** (One-shot, 1-2 seconds)
   - Wind-up
   - Strike
   - Recovery

3. **Hit** (One-shot, 0.5-1 second)
   - Recoil
   - Pain reaction
   - Return to idle

4. **Bonus Time / Stagger** (Loop, can be interrupted)
   - Monster falls to knees
   - Dizzy/stunned look
   - Vulnerable state

5. **Death** (One-shot, 2-3 seconds)
   - Dramatic fall
   - Fade out
   - Dissolve effect (VFX)

---

## 🎭 Visual Effects (VFX)

### Player Attack Effects (show on monster)

**1. Hit Effect (Normal Attack - Punch)**
- Spark particles at impact point
- White/yellow flash
- Sound: punch impact

**2. Critical Hit Effect (Uppercut)**
- Larger spark explosion
- Red/orange particles
- Screen shake (subtle)
- "CRITICAL!" text
- Sound: heavy impact + whoosh

**3. Damage Numbers**
- Pop up from hit location
- Float upward and fade
- Color: white (normal), red (critical)
- Font size based on damage

### Player Defensive Effects (show on player/camera)

**4. Shield Effect**
- Blue energy sphere around camera view
- Particle shimmer
- Duration: 3 seconds
- Sound: shield activate

**5. Dodge Effect**
- Quick screen blur
- Motion lines
- "DODGE!" text
- Sound: whoosh

**6. Heal/Mana Restore Effect**
- Green particles (heal) or blue particles (mana)
- Spiral upward around camera edges
- Glow effect
- Sound: restore chime

### Monster Effects

**7. Boss Attack Warning**
- Red danger indicator
- Build-up particles
- Screen vignette (red edges)
- Sound: warning

**8. Death Effect**
- Monster dissolves into particles
- Light burst
- Victory fanfare
- Slow motion (last 0.5s)

---

## 📱 Performance Optimization Strategy

### Target Specs
- **Minimum:** iPhone 8 / Samsung Galaxy S8
- **Target FPS:** 30 FPS (AR mode)
- **Battery:** <20% drain per 30 min

### Optimization Techniques

1. **Model Optimization**
   - Max 10K polygons for monster
   - 2K texture resolution (1024x1024 for mobile)
   - Texture atlas (combine materials)
   - LOD system (optional for Phase 3)

2. **Animation Optimization**
   - 30 FPS animation keyframes
   - Baked animations (no runtime IK)
   - Animation compression

3. **VFX Optimization**
   - Max 50 particles per effect
   - Simple particle shaders
   - Object pooling for reusable effects
   - Disable effects on low-end devices

4. **AR Optimization**
   - 30 FPS camera processing
   - Downscale AR camera (720p max)
   - Limit plane detection after placement

5. **Rendering Optimization**
   - Single directional light
   - Baked lightmaps where possible
   - Mobile-optimized shaders (URP)
   - Disable shadows on low-end devices

---

## 📨 Flutter ↔ Unity Communication Protocol

### Flutter → Unity Messages

```json
{
  "type": "START_BATTLE",
  "data": {
    "bossId": "monster_001",
    "difficulty": 1
  }
}

{
  "type": "PLAYER_ACTION",
  "data": {
    "action": "PUNCH",  // PUNCH, UPPERCUT, SQUAT, PLANK, HIGH_KNEE
    "damage": 10
  }
}

{
  "type": "BOSS_ATTACK",
  "data": {
    "damage": 15
  }
}

{
  "type": "BATTLE_END",
  "data": {
    "victory": true
  }
}
```

### Unity → Flutter Messages

```json
{
  "type": "UNITY_READY",
  "data": {}
}

{
  "type": "AR_PLANE_DETECTED",
  "data": {
    "canPlace": true
  }
}

{
  "type": "MONSTER_PLACED",
  "data": {
    "position": [0, 0, 0]
  }
}

{
  "type": "ANIMATION_COMPLETE",
  "data": {
    "animation": "attack"
  }
}

{
  "type": "EFFECT_COMPLETE",
  "data": {
    "effect": "hit"
  }
}
```

---

## 🗂️ File Structure (After Phase 2)

```
fitness_game_app/
├── lib/
│   ├── screens/
│   │   └── game/
│   │       ├── boss_battle_screen_3d.dart  (NEW)
│   │       ├── ar_monster_view.dart        (NEW)
│   │       └── game_effects_overlay.dart   (NEW)
│   ├── services/
│   │   ├── unity_service.dart              (NEW)
│   │   └── game_manager.dart               (NEW)
│   └── models/
│       └── game_message.dart               (NEW)
├── unity_project/                           (NEW)
│   ├── Assets/
│   │   ├── Models/
│   │   │   └── MB_10001/
│   │   │       ├── MB_10001.fbx
│   │   │       ├── MB_T_20001.png
│   │   │       └── animations/
│   │   ├── Scripts/
│   │   │   ├── MonsterController.cs
│   │   │   ├── FlutterBridge.cs
│   │   │   ├── VFXManager.cs
│   │   │   └── ARPlacement.cs
│   │   ├── VFX/
│   │   │   ├── Hit.prefab
│   │   │   ├── Critical.prefab
│   │   │   ├── Shield.prefab
│   │   │   └── Death.prefab
│   │   └── Scenes/
│   │       └── GameScene.unity
│   └── ProjectSettings/
└── docs/
    ├── BLENDER_RIGGING_GUIDE.md            (NEW)
    ├── UNITY_SETUP_GUIDE.md                (NEW)
    └── UNITY_EXPORT_GUIDE.md               (NEW)
```

---

## ⚠️ Important Notes

### Unity Requirements
- Unity 2022.3 LTS (recommended)
- Android Build Support module
- iOS Build Support module
- AR Foundation package
- Universal Render Pipeline (URP)

### Device Requirements
- **iOS:** iOS 12+ (ARKit support)
- **Android:** Android 7.0+ with ARCore support

### Limitations
- Unity adds ~150-200MB to app size
- First-time Unity load takes 2-3 seconds
- AR requires good lighting conditions
- Plane detection needs flat surface

---

## 🎯 Success Criteria

### Phase 2A Complete When:
- [ ] Monster is rigged with bones
- [ ] All 5 animations created and exported
- [ ] Unity project opens without errors
- [ ] Monster animates correctly in Unity

### Phase 2B Complete When:
- [ ] AR plane detection works
- [ ] Monster can be placed in AR
- [ ] All animations transition correctly
- [ ] VFX play on command
- [ ] Damage system functional

### Phase 2C Complete When:
- [ ] Flutter can send messages to Unity
- [ ] Unity responds to Flutter commands
- [ ] Boss battle works end-to-end with 3D monster
- [ ] Runs at 30+ FPS on target devices
- [ ] No crashes during normal gameplay

---

## 📚 Next Steps

1. **Read** `BLENDER_RIGGING_GUIDE.md` - Learn how to rig the monster
2. **Read** `UNITY_SETUP_GUIDE.md` - Set up Unity project
3. **Read** `UNITY_EXPORT_GUIDE.md` - Export Unity to Flutter
4. **Implement** Flutter-Unity integration
5. **Test** on real devices (AR requires physical device)

---

**Ready to begin? Start with the Blender guide!** 🚀
