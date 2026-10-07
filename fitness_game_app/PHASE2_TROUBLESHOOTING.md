# Phase 2 Troubleshooting Guide

## 🔧 คู่มือแก้ปัญหา Phase 2

เอกสารนี้รวบรวมปัญหาที่พบบ่อยและวิธีแก้ไขสำหรับทุกขั้นตอนของ Phase 2

---

## 🎨 Blender Issues

### ❌ Problem: "Can't import FBX file"
**Error:** File format not recognized

**Solution:**
```
1. Check Blender version (need 4.0+)
2. File → Preferences → Add-ons
3. Search "FBX"
4. ✅ Enable "Import-Export: FBX format"
5. Retry import
```

---

### ❌ Problem: "Mesh doesn't move when I move bones"
**Error:** Bones and mesh not connected

**Solution:**
```
1. Tab → Object Mode
2. Select Monster mesh FIRST
3. Shift + Select Armature SECOND
4. Ctrl + P → "With Automatic Weights"
5. Wait for calculation
6. Tab → Pose Mode
7. Test: Select bone → R to rotate
```

**If still doesn't work:**
```
Weight Paint method:
1. Select mesh
2. Switch to Weight Paint mode (top dropdown)
3. Select bone in Outliner
4. Paint red (100% influence) on areas that should move
5. Paint blue (0% influence) on areas that shouldn't
```

---

### ❌ Problem: "Mesh stretches weirdly when animating"
**Error:** Bad weight painting

**Solution:**
```
1. Enter Weight Paint mode
2. Select problematic bone
3. Use Weight Paint brush:
   - Reduce weight on stretching areas
   - Add weight to areas that should move more
4. Use "Smooth" brush to blend weights
5. Test in Pose Mode
```

---

### ❌ Problem: "Animation doesn't loop smoothly"
**Error:** First and last keyframes don't match

**Solution:**
```
For looping animations (Idle, Stagger):

1. Timeline: Go to Frame 1
2. Select all bones: A
3. Ctrl + C (copy pose)
4. Go to last frame (90 for Idle)
5. Ctrl + Shift + V (paste pose)
6. I: Insert keyframe

Graph Editor method:
7. Window → Graph Editor
8. Select all curves
9. Channel → Extrapolation Mode → Make Cyclic
```

---

### ❌ Problem: "Exported FBX has no animations"
**Error:** Export settings wrong

**Solution:**
```
File → Export → FBX

Make sure these are checked:
✅ Selected Objects
✅ Armature (in Object Types)
✅ Mesh (in Object Types)
✅ Bake Animation
✅ NLA Strips (if using NLA)
✅ All Actions

Path Format: ASCII (not Binary)
```

---

### ❌ Problem: "Can't see texture on model"
**Error:** Viewport shading mode

**Solution:**
```
Top-right viewport icons:
Click 3rd icon: "Material Preview" mode
(Not wireframe, not solid - the one with sphere)

Or press: Z → Material Preview
```

---

## 🎮 Unity Issues

### ❌ Problem: "Unity won't open/install"
**Error:** Installation or license issue

**Solution:**
```
1. Unity Hub → Sign in with Unity account
2. Add license:
   - Preferences → Licenses
   - Add → "Get a free personal license"
3. Install Unity 2022.3 LTS:
   - Unity Hub → Installs → Install Editor
   - Select 2022.3 LTS
   - Modules:
     ✅ Android Build Support
     ✅ iOS Build Support
     ✅ Documentation
```

---

### ❌ Problem: "Package Manager won't install AR packages"
**Error:** Network or registry issue

**Solution:**
```
Method 1: Check internet connection
Window → Package Manager
Top-left dropdown: "Unity Registry"
Wait for packages to load

Method 2: Manual installation
Window → Package Manager → "+" → Add by name
Type exact names:
- com.unity.xr.arfoundation
- com.unity.xr.arcore
- com.unity.xr.arkit

Method 3: Edit manifest
Close Unity
Open: [Project]/Packages/manifest.json
Add to dependencies:
{
  "dependencies": {
    "com.unity.xr.arfoundation": "5.1.0",
    "com.unity.xr.arcore": "5.1.0",
    "com.unity.xr.arkit": "5.1.0",
    ...
  }
}
Save, reopen Unity
```

---

### ❌ Problem: "Imported monster has no animations"
**Error:** Animation import disabled

**Solution:**
```
1. Select MB_10001_animated.fbx in Project
2. Inspector → Animation tab
3. ✅ Import Animation (must be checked)
4. Click "Apply"
5. Expand FBX in Project view
6. Should see animation clips inside

If still no animations:
- Reimport: Right-click FBX → Reimport
- Check Blender export settings
- Try exporting FBX again from Blender
```

---

### ❌ Problem: "Monster is too big/small in scene"
**Error:** Scale mismatch

**Solution:**
```
Method 1: Change import scale
1. Select FBX
2. Inspector → Model tab
3. Scale Factor: Try 0.01 or 0.1 or 10
4. Apply

Method 2: Scale in scene
1. Select monster in Hierarchy
2. Inspector → Transform
3. Scale: (0.5, 0.5, 0.5) or whatever looks good

Recommended: 1-2 meters tall for AR
```

---

### ❌ Problem: "Animator Controller transitions don't work"
**Error:** Missing parameters or wrong settings

**Solution:**
```
Common issues:

1. Parameter name mismatch:
   - Animator: Parameter called "Attack"
   - Script: animator.SetTrigger("attack") ← wrong case!
   - Fix: Match case exactly

2. Has Exit Time enabled when shouldn't:
   - Select transition arrow
   - Inspector:
   - ❌ Has Exit Time (for trigger transitions)
   - Transition Duration: 0.1-0.2

3. Transition Duration too long:
   - Makes animation feel sluggish
   - Set to 0.1-0.2 for responsive combat

4. Multiple transitions:
   - Only ONE transition can be active
   - Check "Interruption Source" if conflicts
```

---

### ❌ Problem: "Script compilation errors"
**Error:** C# syntax or missing references

**Common errors:**

```csharp
// Error: Type or namespace not found
using UnityEngine.XR.ARFoundation; // Add this

// Error: GameObject is null
private Animator animator;
void Start() {
    animator = GetComponent<Animator>(); // Get reference first
}

// Error: Can't convert int to string
SendMessage("TEST", 123); // Wrong
SendMessage("TEST", "123"); // Correct - needs string

// Error: Object reference not set
public GameObject prefab; // Assign in Inspector!

// Check console for line numbers
Double-click error → opens script at problem line
```

---

### ❌ Problem: "VFX particles don't show up"
**Error:** Wrong settings or not instantiated

**Solution:**
```
Particle System checklist:

1. Duration > 0
2. Start Lifetime > 0
3. Start Speed > 0 (unless stationary)
4. Max Particles > 0
5. Emission: Rate > 0 OR Burst count > 0
6. Renderer:
   - Material assigned (use Default-Particle)
   - Render Mode: Billboard
7. NOT: Play On Awake (for manual VFX)

Testing:
- Select particle system in Hierarchy
- Click "Play" in Inspector
- Should see in Scene view (not Game view in Editor)

Instantiation check:
GameObject effect = Instantiate(prefab, position, Quaternion.identity);
Debug.Log("Spawned: " + effect.name); // Confirm it spawned
```

---

### ❌ Problem: "AR doesn't work in Unity Editor"
**Status:** This is NORMAL

**Explanation:**
```
AR Foundation requires:
- Device camera
- Device sensors (gyroscope, accelerometer)
- ARCore/ARKit runtime

Unity Editor has none of these!

Solution: MUST test on real device

Workaround for testing logic:
- Use debug buttons to trigger functions
- Test animations without AR
- Test VFX without AR
- Only test AR placement on device
```

---

### ❌ Problem: "Build fails with errors"
**Error:** Various build issues

**Solutions by platform:**

**Android:**
```
Error: "Android SDK not found"
→ Edit → Preferences → External Tools
→ Set Android SDK path (install via Unity Hub)

Error: "Gradle build failed"
→ File → Build Settings → Player Settings
→ Min API Level: 24 or higher
→ Scripting Backend: IL2CPP
→ ✅ ARM64

Error: "Keystore not found"
→ Player Settings → Publishing Settings
→ Create new keystore

Error: "Unity library not found"
→ Clean build: Delete Builds folder
→ Rebuild
```

**iOS:**
```
Error: "No Xcode installation found"
→ Install Xcode from Mac App Store (Mac only)

Error: "Provisioning profile"
→ Xcode → Signing & Capabilities
→ Team: Select your Apple Developer account
→ Automatically manage signing

Error: "Framework not found"
→ Build Settings → Search Paths
→ Framework Search Paths: $(inherited)
```

---

## 📱 Flutter Integration Issues

### ❌ Problem: "flutter_unity_widget package not found"
**Error:** Package doesn't install

**Solution:**
```
Try alternatives:

Method 1: flutter_unity_widget (recommended)
pubspec.yaml:
dependencies:
  flutter_unity_widget: ^2022.2.0

Method 2: From GitHub directly
dependencies:
  flutter_unity_widget:
    git:
      url: https://github.com/juicycleff/flutter-unity-view-widget.git
      ref: main

Method 3: Use platform channels (manual)
- Implement native Android/iOS bridges
- More complex but more control
```

---

### ❌ Problem: "Unity widget shows black screen"
**Error:** Unity not initialized or crashed

**Debug steps:**
```
1. Check device logs:

Android:
adb logcat | grep Unity

iOS:
Xcode → Window → Devices and Simulators
→ View Device Logs

2. Check Unity export completed:
- Builds/Android/ should have unityLibrary folder
- Builds/iOS/ should have Unity-iPhone.xcodeproj

3. Check UnityWidgetController initialized:
void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
    print("Unity initialized: ${controller != null}"); // Debug
}

4. Check AR permissions granted:
- Camera permission
- Location permission (some devices)

5. Try simple test:
- Create empty Unity scene with just a cube
- Export and test
- If cube shows, issue is with game scene
```

---

### ❌ Problem: "Can't send messages to Unity"
**Error:** Bridge not setup correctly

**Solution:**
```dart
// Flutter side
void sendMessage() {
  if (_unityController == null) {
    print("ERROR: Unity controller is null!");
    return;
  }
  
  _unityController!.postMessage(
    'FlutterBridge',  // GameObject name (must exist in Unity!)
    'OnFlutterMessage', // Method name
    '{"type":"TEST"}', // Message (string!)
  );
}

// Unity side - check GameObject exists
Hierarchy → Must have "FlutterBridge" GameObject
That GameObject → Must have FlutterBridge.cs script

// Unity side - check method signature
public void OnFlutterMessage(string message) {  // Must be public!
    Debug.Log("Received: " + message);
}

// If still doesn't work: Use Unity callbacks
Unity → Flutter works even if Flutter → Unity doesn't
```

---

### ❌ Problem: "App crashes when opening AR"
**Error:** Various crash causes

**Debug approach:**
```
1. Check crash logs:

Android:
adb logcat *:E
(shows only errors)

iOS:
Xcode → Window → Devices and Simulators
→ View Device Logs
→ Filter by your app name

2. Common crash causes:

a) Missing AR support:
- Device doesn't have ARCore/ARKit
- Check: Device specs online

b) Missing permissions:
- AndroidManifest.xml must have camera permission
- Info.plist must have camera usage description

c) Unity export incomplete:
- Check Builds folder has all files
- Try clean rebuild

d) Memory issue:
- Lower model polycount
- Reduce texture sizes
- Limit particle count

3. Incremental testing:
- Test with just Unity widget (no AR)
- Add AR Session Origin
- Add monster
- Add VFX
- Find where it crashes
```

---

## 🎯 Device-Specific Issues

### ❌ Problem: "AR plane detection not working"
**Symptoms:** Camera works but monster never appears

**Solutions by cause:**

**1. Poor lighting:**
```
- Need bright, even lighting
- No direct sunlight (too bright)
- No dim rooms (too dark)
- Test near window during daytime
```

**2. No flat surface:**
```
- Point at floor, table, or desk
- Surface must be:
  - Flat (not curved)
  - Textured (not plain white)
  - Stationary (not moving)
- Move device slowly in sweeping motion
- Keep 1-2 meters from surface
```

**3. Device too old:**
```
Check ARCore/ARKit support:

Android: https://developers.google.com/ar/devices
iOS: iPhone 6S or newer

If device not supported → Won't work, need different device
```

**4. AR disabled:**
```
Unity: AR Session Origin → AR Plane Manager
- ✅ Enabled checkbox
- Detection Mode: Horizontal
- Plane Prefab: Can be empty
```

---

### ❌ Problem: "Monster appears but is shaking/jittery"
**Error:** Tracking instability

**Solution:**
```
1. Improve tracking conditions:
   - Better lighting
   - More textured surface
   - Move device slower

2. Smooth position updates:

C# (Unity):
void Update() {
    // Instead of instant position change:
    transform.position = targetPosition; // Jittery
    
    // Use lerp (smooth):
    transform.position = Vector3.Lerp(
        transform.position,
        targetPosition,
        Time.deltaTime * smoothSpeed // smoothSpeed = 5f
    );
}

3. Anchor to plane:
- Use AR Anchor component
- Attach monster to detected plane
```

---

### ❌ Problem: "Performance is bad (low FPS)"
**Symptoms:** Laggy, choppy animation

**Optimization steps:**

```
1. Check current FPS:

Unity:
void OnGUI() {
    float fps = 1.0f / Time.deltaTime;
    GUI.Label(new Rect(10, 10, 100, 20), "FPS: " + (int)fps);
}

Target: 30+ FPS

2. Reduce model quality:
   - Decimate monster mesh (fewer polygons)
   - Lower texture resolution: 512x512 or 1024x1024
   - Single material (no multiple materials)

3. Optimize particles:
   - Max Particles: Reduce to 30-50
   - Rate over Time: Reduce
   - Disable particles on low-end devices

4. Reduce shadows:
   - Quality Settings → Shadow Distance: 10-20
   - Disable shadows on monster

5. Optimize scripts:
   - Avoid GetComponent in Update()
   - Cache all component references
   - Use object pooling for VFX

6. Device-specific:
   - Lower Android: Min Quality Settings
   - Test on target device, not flagship
```

---

## 🔍 Debugging Tips

### Enable Debug Logs

**Unity:**
```csharp
void Start() {
    Debug.Log("Monster initialized");
}

void TakeDamage(int damage) {
    Debug.Log($"Took {damage} damage, HP: {currentHealth}");
}

// View logs:
// Unity Editor: Console window
// Android: adb logcat -s Unity
// iOS: Xcode console
```

**Flutter:**
```dart
void _performAction(PoseType pose) {
  print('DEBUG: Action $pose triggered');
  // ... action logic
}

// View logs:
// flutter run → logs in terminal
// or: flutter logs
```

---

### Test Without AR First

```
Create test scene:
1. Regular camera (not AR Camera)
2. Monster in scene (not spawned)
3. Test animations with buttons
4. Verify VFX work
5. Verify scripts work

Then enable AR after basics work!
```

---

### Use Debug Buttons

```dart
// In AR battle screen - add test UI
Widget _buildDebugPanel() {
  if (!kDebugMode) return SizedBox.shrink();
  
  return Container(
    color: Colors.black54,
    child: Row(
      children: [
        TextButton(
          onPressed: () => _unityService.playerAction('PUNCH', 10),
          child: Text('Test Punch'),
        ),
        TextButton(
          onPressed: () => _unityService.playerAction('UPPERCUT', 25),
          child: Text('Test Critical'),
        ),
        // ... more buttons
      ],
    ),
  );
}
```

---

## 📚 Where to Get Help

### Documentation
- Unity AR Foundation: https://docs.unity3d.com/Packages/com.unity.xr.arfoundation@5.1/manual/
- Blender Manual: https://docs.blender.org/
- Flutter: https://docs.flutter.dev/

### Communities
- Unity Forum: https://forum.unity.com/
- Blender Artists: https://blenderartists.org/
- Flutter Discord: https://github.com/flutter/flutter/wiki/Chat
- Stack Overflow: Tag with unity3d, blender, flutter

### Video Tutorials
- YouTube: "Unity AR Foundation tutorial"
- YouTube: "Blender rigging for beginners"
- YouTube: "Flutter Unity integration"

### When Asking for Help
```
Include:
1. What you were trying to do
2. What happened instead
3. Error messages (full text)
4. Unity/Flutter versions
5. Device model and OS version
6. Screenshots/videos of issue

Example good question:
"Unity AR plane detection not working on Samsung S10.
Unity 2022.3, AR Foundation 5.1.0, Android 12.
Camera opens but monster never spawns.
Logs show: [paste logs]
Testing on wooden table with good lighting."
```

---

## ✅ Verification Checklist

Before asking for help, verify:

- [ ] Followed guide step-by-step
- [ ] No compilation errors
- [ ] Tested on physical device (not emulator)
- [ ] Permissions granted (camera, storage)
- [ ] Good lighting and flat surface
- [ ] Checked logs for errors
- [ ] Tried clean rebuild
- [ ] Searched error message online
- [ ] Tested each component separately

---

## 🎯 Still Stuck?

**Option 1: Simplify**
- Skip VFX, just get monster working
- Skip AR, test with regular camera first
- Use simpler animations
- Test with Unity cube before custom model

**Option 2: Alternative Approach**
- Use Mixamo for auto-rigging
- Use Asset Store for VFX
- Use pre-made AR templates
- Consider 2D sprites instead of 3D

**Option 3: Focus on Core Game**
- Skip Unity integration for now
- Use placeholder 2D boss sprite
- Keep MediaPipe combat system
- Add 3D later when time allows

Remember: **Working simple version > Broken complex version** ✨
