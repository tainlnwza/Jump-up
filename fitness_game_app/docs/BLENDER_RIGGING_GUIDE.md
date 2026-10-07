# Blender Monster Rigging & Animation Guide

## 🎯 Objective
Rig the lowpoly monster model (MB_10001.fbx) and create 5 animations for the fitness game.

**Time Required:** 6-9 hours total
- Rigging: 2-3 hours
- Animation: 4-6 hours

---

## 📋 Prerequisites

### Software
- **Blender 4.0+** (Download: https://www.blender.org/download/)
- MB_10001.fbx from `D:\MB_10001\`
- Textures: MB_T_20001.png, MB_T_20001_S.png, lvguang2.png

### Knowledge Level
- Basic Blender navigation (not required - this guide covers everything)
- No animation experience needed

---

## 🦴 Part 1: Monster Rigging (2-3 hours)

### Step 1: Import Model

1. **Launch Blender**
   - Delete default cube (X → Delete)
   - Keep camera and light

2. **Import FBX**
   ```
   File → Import → FBX (.fbx)
   Navigate to: D:\MB_10001\MB_10001.fbx
   Click "Import FBX"
   ```

3. **Verify Import**
   - Monster should appear in center
   - Select monster: Left-click on it
   - Numpad 1: Front view
   - Numpad 7: Top view
   - Numpad 3: Side view
   - Mouse wheel: Zoom in/out
   - Middle mouse drag: Rotate view

4. **Apply Textures**
   ```
   1. Select monster
   2. Switch to "Shading" workspace (top tabs)
   3. In Shader Editor (bottom):
      - Select "Base Color" yellow dot
      - Add → Texture → Image Texture
      - Click folder icon → select MB_T_20001.png
      - Connect Image Color → Base Color
   4. Switch viewport to "Material Preview" (top-right, 3rd icon)
   5. Monster should now show texture
   ```

### Step 2: Create Armature (Skeleton)

1. **Add Armature**
   ```
   Shift + A → Armature → Single Bone
   ```

2. **Enter Edit Mode**
   ```
   Select armature → Tab (enters Edit Mode)
   ```

3. **Position Root Bone**
   ```
   - G: Move bone
   - S: Scale bone
   - R: Rotate bone
   - Place root bone at monster's hip/pelvis
   ```

4. **Create Bone Hierarchy** (Total: 13-15 bones)

   **Core Bones:**
   ```
   Root (hip)
   ├── Spine_Lower
   ├── Spine_Upper
   ├── Neck
   └── Head
   ```

   **Leg Bones (both sides):**
   ```
   Root
   ├── Thigh_L
   │   ├── Shin_L
   │   └── Foot_L
   └── Thigh_R
       ├── Shin_R
       └── Foot_R
   ```

   **Arm Bones (both sides):**
   ```
   Spine_Upper
   ├── Shoulder_L
   │   ├── UpperArm_L
   │   ├── ForeArm_L
   │   └── Hand_L
   └── Shoulder_R
       ├── UpperArm_R
       ├── ForeArm_R
       └── Hand_R
   ```

5. **How to Add Child Bones**
   ```
   - Select bone tip (orange ball)
   - E: Extrude (creates connected child bone)
   - Move mouse to position
   - Click to place
   - Or: Shift+A → Add Bone (disconnected)
   ```

6. **Naming Bones**
   ```
   - Select bone
   - Properties Panel (right side) → Bone Properties (bone icon)
   - Change name
   - Use "_L" and "_R" suffixes (Blender auto-mirrors)
   ```

### Step 3: Skinning (Weight Painting)

1. **Parent Mesh to Armature**
   ```
   - Tab: Exit Edit Mode (back to Object Mode)
   - Select Monster mesh first
   - Shift + Select Armature
   - Ctrl + P → With Automatic Weights
   ```

2. **Test Pose**
   ```
   - Select Armature
   - Tab: Enter Pose Mode (not Edit Mode!)
   - Select any bone
   - R: Rotate bone
   - Monster mesh should deform
   - Ctrl + Z: Undo to reset
   ```

3. **Fix Weight Paint (if needed)**
   ```
   - Select Monster mesh
   - Switch to Weight Paint mode (top-left dropdown)
   - Select bone you want to fix (in outliner)
   - Paint with brush:
     - Red = 100% influence
     - Blue = 0% influence
   - Smooth transitions between bones
   ```

4. **Return to Object Mode**
   ```
   Tab → Object Mode
   ```

### Step 4: Save Rigged Model

```
File → Save As → MB_10001_rigged.blend
Location: D:\MB_10001\MB_10001_rigged.blend
```

---

## 🎬 Part 2: Animation Creation (4-6 hours)

### Animation Settings

1. **Set Timeline**
   ```
   Bottom panel: Timeline
   End Frame: 150 (default is 250)
   Frame Rate: 30 FPS
   ```

2. **Switch to Animation Workspace**
   ```
   Top tabs: Click "Animation"
   ```

### Animation 1: Idle (Loop, 90 frames = 3 seconds)

**Goal:** Breathing, subtle movement

1. **Setup**
   ```
   - Select Armature → Pose Mode
   - Timeline: Set End Frame to 90
   - Frame 1: Press I → LocRotScale (sets keyframe on all bones)
   ```

2. **Animate Breathing (Frame 45 - mid)**
   ```
   - Move timeline to frame 45
   - Select Spine_Lower, Spine_Upper bones
   - S: Scale slightly larger (1.05x)
   - G Z: Move up slightly
   - I: Insert keyframe → LocRotScale
   ```

3. **Return to Start (Frame 90)**
   ```
   - Frame 90: Same pose as Frame 1
   - Select all bones: A
   - I: Insert keyframe → LocRotScale
   ```

4. **Add Head Movement**
   ```
   - Frame 30: Head rotates slightly left
   - Frame 60: Head rotates slightly right
   - Insert keyframes each time
   ```

5. **Set Loop**
   ```
   - Select all keyframes in Dope Sheet
   - Channel → Extrapolation Mode → Make Cyclic
   ```

6. **Save Animation**
   ```
   - In Action Editor: Click "+" → New Action
   - Name: "Monster_Idle"
   - Push down arrow (stashes animation)
   ```

### Animation 2: Attack (One-shot, 60 frames = 2 seconds)

**Goal:** Wind-up, strike, recover

1. **New Action**
   ```
   - Action Editor: "+" New
   - Name: "Monster_Attack"
   - Timeline: 0-60 frames
   ```

2. **Frame 1: Idle pose**
   ```
   Select all bones → I → LocRotScale
   ```

3. **Frame 15: Wind-up**
   ```
   - Right arm pulls back
   - Spine rotates right
   - Weight shifts to back leg
   - Insert keyframes
   ```

4. **Frame 30: Strike!**
   ```
   - Right arm extends forward (punch)
   - Spine rotates left (follow-through)
   - Weight shifts to front leg
   - Insert keyframes
   ```

5. **Frame 60: Recover to idle**
   ```
   - Return to starting pose
   - Insert keyframes
   ```

6. **Save**: Push down arrow (stash)

### Animation 3: Hit (One-shot, 20 frames = 0.67 seconds)

**Goal:** Quick recoil reaction

1. **New Action: "Monster_Hit"**

2. **Frame 1: Normal pose**

3. **Frame 10: Recoil back**
   ```
   - Entire body moves back (G Y: move backward)
   - Spine bends backward
   - Head snaps back
   - Arms react
   ```

4. **Frame 20: Recover**
   ```
   - Return to idle-ish pose
   ```

### Animation 4: Bonus Time / Stagger (Loop, 120 frames = 4 seconds)

**Goal:** Monster is stunned, vulnerable

1. **New Action: "Monster_Stagger"**

2. **Frame 1: Start falling**
   ```
   - Legs start to bend (squat position)
   ```

3. **Frame 30: On knees**
   ```
   - Monster kneels down
   - Thigh bones rotate 90°
   - Shin bones parallel to ground
   - Head hangs down
   - Arms support on ground
   ```

4. **Frame 60: Swaying left**
   ```
   - Spine sways left slightly
   - Head wobbles
   ```

5. **Frame 90: Swaying right**
   ```
   - Spine sways right
   ```

6. **Frame 120: Return to frame 30 pose** (loop)

7. **Set Loop**: Extrapolation → Make Cyclic

### Animation 5: Death (One-shot, 90 frames = 3 seconds)

**Goal:** Dramatic fall and defeat

1. **New Action: "Monster_Death"**

2. **Frame 1: Standing (hit pose)**

3. **Frame 20: Stagger**
   ```
   - Legs wobble
   - Arms flail
   ```

4. **Frame 40: Falling**
   ```
   - Body tilts forward
   - Legs give out
   - Arms trying to balance
   ```

5. **Frame 60: Impact ground**
   ```
   - Monster flat on ground
   - Face down
   - Arms spread
   - Legs bent
   ```

6. **Frame 90: Final rest**
   ```
   - Slight settling
   - All movement stops
   ```

---

## 📤 Part 3: Export for Unity

### Export Rigged Model with All Animations

1. **Select Objects**
   ```
   - Select Armature
   - Shift + Select Monster Mesh
   ```

2. **Export FBX**
   ```
   File → Export → FBX (.fbx)
   
   Settings:
   ✅ Selected Objects
   ✅ Limit to: Selected Objects
   ✅ Object Types: Armature, Mesh
   ✅ Bake Animation
   ✅ All Actions (exports all animations)
   
   Path: D:\MB_10001\MB_10001_animated.fbx
   
   Click "Export FBX"
   ```

3. **Export Textures** (already have them)
   ```
   Copy to Unity project later:
   - MB_T_20001.png
   - MB_T_20001_S.png
   - lvguang2.png
   ```

---

## ✅ Verification Checklist

Before moving to Unity:

- [ ] Monster has armature with 13-15 bones
- [ ] Mesh deforms when bones move in Pose Mode
- [ ] **Idle** animation loops smoothly
- [ ] **Attack** animation: wind-up → strike → recover
- [ ] **Hit** animation: recoil reaction
- [ ] **Stagger** animation: monster on knees, looping
- [ ] **Death** animation: dramatic fall
- [ ] Exported FBX file: `MB_10001_animated.fbx`
- [ ] File size: 2-5 MB (reasonable)

---

## 🎓 Blender Hotkeys Reference

### Navigation
- **Middle Mouse Drag**: Rotate view
- **Shift + Middle Mouse**: Pan view
- **Scroll Wheel**: Zoom
- **Numpad 1/3/7**: Front/Side/Top view
- **Numpad 0**: Camera view

### Selection
- **Left Click**: Select
- **A**: Select all
- **Alt + A**: Deselect all
- **B**: Box select
- **C**: Circle select

### Manipulation
- **G**: Move (Grab)
- **R**: Rotate
- **S**: Scale
- **X/Y/Z** (after G/R/S): Constrain to axis
- **Tab**: Switch Edit/Object mode

### Animation
- **I**: Insert keyframe
- **Alt + G/R/S**: Reset position/rotation/scale
- **Spacebar**: Play animation

---

## 🆘 Troubleshooting

### Problem: Bones don't move mesh
**Solution:** Re-parent with automatic weights
```
Select Mesh → Shift+Select Armature → Ctrl+P → With Automatic Weights
```

### Problem: Animation doesn't export
**Solution:** Make sure "Bake Animation" is checked in FBX export

### Problem: Mesh stretches weirdly
**Solution:** Fix weight painting - paint bone influence in Weight Paint mode

### Problem: Can't see model
**Solution:** Press Numpad . (period) to frame selected object

### Problem: Texture is black
**Solution:** Switch viewport shading to "Material Preview" (top-right icons)

---

## 📚 Additional Resources

- **Blender Manual**: https://docs.blender.org/manual/en/latest/
- **Rigging Tutorial**: https://www.youtube.com/watch?v=... (search "Blender rigging tutorial")
- **Animation Tutorial**: https://www.youtube.com/watch?v=... (search "Blender animation basics")

---

**🎉 After completing this guide, you'll have:**
- `MB_10001_animated.fbx` with 5 animations ready for Unity
- Knowledge to modify or add more animations later

**Next Step:** Follow `UNITY_SETUP_GUIDE.md` to import into Unity! 🚀
