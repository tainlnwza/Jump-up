# ADR-002: Client-Side MediaPipe Processing for Pose Detection

**Date:** 2026-09-13  
**Status:** Accepted  
**Decision Makers:** System Architect  

## Context

The application requires real-time pose detection for both game mode (boss battles) and workout mode (exercise tracking). We need to decide whether to process video on-device or send to a server.

## Decision

**Process pose detection on-device using MediaPipe Flutter plugin** with on-device ML models.

## Rationale

### Technical Justification

1. **Latency Requirements**
   - Game mode needs <100ms response time for QTE (quick-time events)
   - Network round-trip would add 200-500ms latency
   - On-device processing: 30-50ms per frame
   - **Server processing would break gameplay feel**

2. **Privacy & User Trust**
   - No video data leaves device
   - Users exercising in home environment (sensitive)
   - GDPR/privacy compliance easier
   - No storage of workout videos on servers

3. **Cost Efficiency**
   - Zero server costs for pose processing
   - Zero bandwidth costs for video upload
   - Scales naturally with users (each device does own processing)
   - **Free tier of backend services can support many more users**

4. **Offline Capability**
   - Can work without internet after initial download
   - Rural areas or poor connectivity still functional
   - Better user experience in gyms with weak WiFi

### Performance Considerations

Modern smartphones (2020+) can handle MediaPipe:
- iPhone 8+ and Android equivalents are sufficient
- GPU acceleration available on most devices
- Battery impact: ~5-10% per 30-minute session (acceptable)

### Technical Feasibility

```dart
// Proven implementation with google_mlkit_pose_detection
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// Optimizations:
- Process every 3rd frame (10 FPS sufficient for pose validation)
- Use PoseDetectionMode.stream for real-time
- Lower camera resolution to 720p
- Pre-warm model on app launch
```

## Alternatives Considered

### Alternative 1: Server-Side Processing
**Rejected because:**
- Adds 200-500ms latency (unacceptable for QTE game)
- Requires video upload (bandwidth cost + privacy concerns)
- Server costs scale with usage
- Requires stable internet connection
- More complex infrastructure

### Alternative 2: Hybrid (Server for Workout, Client for Game)
**Rejected because:**
- Complexity of maintaining two processing paths
- Workout mode also benefits from low latency
- Minimal benefit: server processing not meaningfully better for accuracy
- Code duplication and maintenance burden

## Consequences

### Positive
- Excellent user experience (responsive, private)
- Zero marginal cost per user
- Simpler backend architecture
- Works offline
- Faster development (no server ML infrastructure needed)

### Negative
- Requires minimum device capabilities (iPhone 7+ / Android 7+)
- Battery consumption during use
- Cannot collect pose data for model improvement without explicit user consent
- Harder to debug issues (can't inspect server-side logs)

### Mitigations
- Display device compatibility warning on old devices
- Optimize processing (frame skipping, resolution limiting)
- Implement optional telemetry with user consent
- Add local logging for debugging

## Device Requirements

**Minimum Specifications:**
- iOS: iPhone 7 or later (iOS 12+)
- Android: Android 7.0+ with ARCore support
- 2GB+ RAM
- Camera: 720p @ 30fps minimum

**Recommended:**
- iOS: iPhone X or later
- Android: Snapdragon 660+ or equivalent
- 3GB+ RAM

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Pose detection latency | <50ms | 95th percentile |
| Frame processing rate | 10-15 FPS | Average during session |
| Battery drain | <15% per 30min | Measured on reference devices |
| Pose accuracy | >90% | Correct pose detection rate |

## Fallback Strategy

If user device cannot handle on-device processing:
1. Detect device capability on app launch
2. Show warning: "Your device may not support all features"
3. Offer degraded mode: timer-based workouts without pose validation
4. Suggest device upgrade for full experience

## Review Date
Review after user testing with at least 50 users across different devices.
