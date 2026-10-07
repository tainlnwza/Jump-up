import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../config/env.dart';

enum PoseType {
  punch,
  uppercut,
  squat,
  plank,
  highKnee,
  unknown,
}

class PoseDetectionResult {
  final PoseType poseType;
  final double confidence;
  final List<PoseLandmark> landmarks;

  PoseDetectionResult({
    required this.poseType,
    required this.confidence,
    required this.landmarks,
  });
}

class MediaPipeService {
  PoseDetector? _poseDetector;
  CameraController? _cameraController;
  bool _isProcessing = false;
  int _frameCount = 0;

  /// Initialize MediaPipe pose detector
  Future<void> initialize() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    );
    _poseDetector = PoseDetector(options: options);
  }

  /// Initialize camera
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    // Use front camera for selfie mode
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium, // 720p for balance between quality and performance
      enableAudio: false,
    );

    await _cameraController!.initialize();
  }

  /// Process camera image and detect pose
  Future<PoseDetectionResult?> processCameraImage(CameraImage image) async {
    // Process every Nth frame to maintain target FPS
    _frameCount++;
    if (_frameCount % Environment.processEveryNthFrame != 0) {
      return null;
    }

    if (_isProcessing || _poseDetector == null) {
      return null;
    }

    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage for MLKit
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return null;

      // Detect poses
      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isEmpty) {
        return null;
      }

      final pose = poses.first;

      // Validate and classify pose
      final poseType = _classifyPose(pose.landmarks);
      final confidence = _calculateConfidence(pose.landmarks);

      if (confidence < Environment.poseDetectionConfidenceThreshold) {
        return null;
      }

      return PoseDetectionResult(
        poseType: poseType,
        confidence: confidence,
        landmarks: pose.landmarks.values.toList(),
      );
    } catch (e) {
      print('Error processing image: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Classify detected pose into one of the 5 exercise poses
  PoseType _classifyPose(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    // Get key landmarks
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    if (leftShoulder == null || rightShoulder == null) {
      return PoseType.unknown;
    }

    // Punch: arm extended forward
    if (_isPunchPose(leftShoulder, leftElbow, leftWrist, rightShoulder, rightElbow, rightWrist)) {
      return PoseType.punch;
    }

    // Uppercut: arm upward motion
    if (_isUppercutPose(leftShoulder, leftElbow, leftWrist, rightShoulder, rightElbow, rightWrist)) {
      return PoseType.uppercut;
    }

    // Squat: knees bent, hips lowered
    if (_isSquatPose(leftHip, leftKnee, leftAnkle, rightHip, rightKnee, rightAnkle)) {
      return PoseType.squat;
    }

    // Plank: body horizontal, arms extended
    if (_isPlankPose(leftShoulder, leftHip, leftAnkle, rightShoulder, rightHip, rightAnkle)) {
      return PoseType.plank;
    }

    // High Knee: knee raised high
    if (_isHighKneePose(leftHip, leftKnee, rightHip, rightKnee)) {
      return PoseType.highKnee;
    }

    return PoseType.unknown;
  }

  bool _isPunchPose(
    PoseLandmark leftShoulder,
    PoseLandmark? leftElbow,
    PoseLandmark? leftWrist,
    PoseLandmark rightShoulder,
    PoseLandmark? rightElbow,
    PoseLandmark? rightWrist,
  ) {
    if (leftElbow == null || leftWrist == null || rightElbow == null || rightWrist == null) {
      return false;
    }

    // Check if either arm is extended forward (wrist significantly in front of shoulder)
    final leftArmExtended = leftWrist.x > leftShoulder.x + 0.2;
    final rightArmExtended = rightWrist.x < rightShoulder.x - 0.2;

    return leftArmExtended || rightArmExtended;
  }

  bool _isUppercutPose(
    PoseLandmark leftShoulder,
    PoseLandmark? leftElbow,
    PoseLandmark? leftWrist,
    PoseLandmark rightShoulder,
    PoseLandmark? rightElbow,
    PoseLandmark? rightWrist,
  ) {
    if (leftElbow == null || leftWrist == null || rightElbow == null || rightWrist == null) {
      return false;
    }

    // Check if either arm has upward motion (wrist above shoulder)
    final leftArmUp = leftWrist.y < leftShoulder.y - 0.2;
    final rightArmUp = rightWrist.y < rightShoulder.y - 0.2;

    return leftArmUp || rightArmUp;
  }

  bool _isSquatPose(
    PoseLandmark? leftHip,
    PoseLandmark? leftKnee,
    PoseLandmark? leftAnkle,
    PoseLandmark? rightHip,
    PoseLandmark? rightKnee,
    PoseLandmark? rightAnkle,
  ) {
    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null) {
      return false;
    }

    // Check if knees are bent and hips are lowered
    final leftKneeBent = leftKnee.y < leftHip.y + 0.3;
    final rightKneeBent = rightKnee.y < rightHip.y + 0.3;

    return leftKneeBent && rightKneeBent;
  }

  bool _isPlankPose(
    PoseLandmark leftShoulder,
    PoseLandmark? leftHip,
    PoseLandmark? leftAnkle,
    PoseLandmark rightShoulder,
    PoseLandmark? rightHip,
    PoseLandmark? rightAnkle,
  ) {
    if (leftHip == null || leftAnkle == null || rightHip == null || rightAnkle == null) {
      return false;
    }

    // Check if body is roughly horizontal
    final leftBodyAlignment = (leftShoulder.y - leftHip.y).abs() < 0.2;
    final rightBodyAlignment = (rightShoulder.y - rightHip.y).abs() < 0.2;

    return leftBodyAlignment && rightBodyAlignment;
  }

  bool _isHighKneePose(
    PoseLandmark? leftHip,
    PoseLandmark? leftKnee,
    PoseLandmark? rightHip,
    PoseLandmark? rightKnee,
  ) {
    if (leftHip == null || leftKnee == null || rightHip == null || rightKnee == null) {
      return false;
    }

    // Check if either knee is raised high
    final leftKneeRaised = leftKnee.y < leftHip.y - 0.1;
    final rightKneeRaised = rightKnee.y < rightHip.y - 0.1;

    return leftKneeRaised || rightKneeRaised;
  }

  double _calculateConfidence(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    // Calculate average confidence from key landmarks
    final keyLandmarks = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    ];

    double totalConfidence = 0;
    int count = 0;

    for (final type in keyLandmarks) {
      final landmark = landmarks[type];
      if (landmark != null) {
        totalConfidence += landmark.likelihood;
        count++;
      }
    }

    return count > 0 ? totalConfidence / count : 0.0;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    // This is a simplified version
    // In production, you'd need proper image conversion based on platform
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      print('Error converting image: $e');
      return null;
    }
  }

  CameraController? get cameraController => _cameraController;

  Future<void> dispose() async {
    await _poseDetector?.close();
    await _cameraController?.dispose();
  }
}
