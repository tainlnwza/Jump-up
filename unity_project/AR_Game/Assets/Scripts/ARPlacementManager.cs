// Unity C# Script: ARPlacementManager.cs
// Location: unity_project/Assets/Scripts/ARPlacementManager.cs

using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;

[RequireComponent(typeof(ARRaycastManager))]
[RequireComponent(typeof(ARPlaneManager))]
public class ARPlacementManager : MonoBehaviour
{
    [Header("AR Components")]
    private ARRaycastManager raycastManager;
    private ARPlaneManager planeManager;

    [Header("Monster")]
    public GameObject monsterPrefab;
    private GameObject spawnedMonster;
    private bool monsterPlaced = false;

    [Header("Placement Settings")]
    public float distanceFromCamera = 2f;
    public float minDistanceFromCamera = 1f;
    public float maxDistanceFromCamera = 5f;

    [Header("Plane Detection")]
    private bool planeDetected = false;
    private float planeDetectionTime = 0f;
    private const float AUTO_PLACE_DELAY = 1.5f;

    private List<ARRaycastHit> hits = new List<ARRaycastHit>();

    void Start()
    {
        raycastManager = GetComponent<ARRaycastManager>();
        planeManager = GetComponent<ARPlaneManager>();

        if (monsterPrefab == null)
        {
            Debug.LogError("[ARPlacement] Monster prefab not assigned!");
        }

        Debug.Log("[ARPlacement] Initialized");
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
            if (!planeDetected)
            {
                planeDetected = true;
                planeDetectionTime = Time.time;
                Debug.Log("[ARPlacement] Plane detected");

                // Notify Flutter
                FlutterBridge.SendMessage("AR_PLANE_DETECTED", "{\"canPlace\":true}");
            }

            // Auto-place after stable detection
            if (Time.time - planeDetectionTime >= AUTO_PLACE_DELAY)
            {
                PlaceMonster(hits[0].pose);
            }
        }
        else
        {
            // Reset detection timer if plane lost
            if (planeDetected)
            {
                planeDetectionTime = Time.time;
            }
        }
    }

    void PlaceMonster(Pose hitPose)
    {
        if (monsterPlaced || monsterPrefab == null) return;

        Camera arCamera = Camera.main;
        if (arCamera == null)
        {
            Debug.LogError("[ARPlacement] Main camera not found");
            return;
        }

        // Calculate position in front of camera at specified distance
        Vector3 cameraPosition = arCamera.transform.position;
        Vector3 cameraForward = arCamera.transform.forward;
        cameraForward.y = 0; // Keep on ground plane
        cameraForward.Normalize();

        Vector3 spawnPosition = cameraPosition + cameraForward * distanceFromCamera;

        // Use detected plane height
        spawnPosition.y = hitPose.position.y;

        // Validate distance
        float distanceToCamera = Vector3.Distance(cameraPosition, spawnPosition);
        if (distanceToCamera < minDistanceFromCamera || distanceToCamera > maxDistanceFromCamera)
        {
            Debug.LogWarning($"[ARPlacement] Distance out of range: {distanceToCamera}m");
            return;
        }

        // Spawn monster
        spawnedMonster = Instantiate(monsterPrefab, spawnPosition, Quaternion.identity);

        // Rotate to face camera
        Vector3 lookDirection = arCamera.transform.position - spawnedMonster.transform.position;
        lookDirection.y = 0;
        if (lookDirection != Vector3.zero)
        {
            spawnedMonster.transform.rotation = Quaternion.LookRotation(lookDirection);
        }

        monsterPlaced = true;

        // Disable plane visualization
        DisablePlaneVisualization();

        Debug.Log($"[ARPlacement] Monster placed at {spawnPosition}");

        // Notify Flutter
        string json = $"{{\"position\":[{spawnPosition.x},{spawnPosition.y},{spawnPosition.z}]}}";
        FlutterBridge.SendMessage("MONSTER_PLACED", json);

        // Add placement animation
        StartCoroutine(SpawnAnimation());
    }

    System.Collections.IEnumerator SpawnAnimation()
    {
        if (spawnedMonster == null) yield break;

        Vector3 startScale = Vector3.zero;
        Vector3 endScale = Vector3.one;
        float duration = 0.5f;
        float elapsed = 0f;

        Transform monsterTransform = spawnedMonster.transform;
        Vector3 startPos = monsterTransform.position;
        Vector3 endPos = startPos;
        startPos.y -= 0.5f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            // Ease out
            t = 1f - Mathf.Pow(1f - t, 3f);

            monsterTransform.localScale = Vector3.Lerp(startScale, endScale, t);
            monsterTransform.position = Vector3.Lerp(startPos, endPos, t);

            yield return null;
        }

        monsterTransform.localScale = endScale;
        monsterTransform.position = endPos;
    }

    void DisablePlaneVisualization()
    {
        planeManager.enabled = false;

        foreach (var plane in planeManager.trackables)
        {
            plane.gameObject.SetActive(false);
        }

        Debug.Log("[ARPlacement] Plane visualization disabled");
    }

    public void ResetPlacement()
    {
        if (spawnedMonster != null)
        {
            Destroy(spawnedMonster);
            spawnedMonster = null;
        }

        monsterPlaced = false;
        planeDetected = false;
        planeDetectionTime = 0f;

        // Re-enable plane detection
        planeManager.enabled = true;

        foreach (var plane in planeManager.trackables)
        {
            plane.gameObject.SetActive(true);
        }

        Debug.Log("[ARPlacement] Placement reset");

        FlutterBridge.SendMessage("PLACEMENT_RESET", "{}");
    }

    // Manual placement (if needed)
    public void PlaceMonsterAtPosition(Vector3 position)
    {
        if (monsterPlaced || monsterPrefab == null) return;

        spawnedMonster = Instantiate(monsterPrefab, position, Quaternion.identity);

        // Rotate to face camera
        if (Camera.main != null)
        {
            Vector3 lookDirection = Camera.main.transform.position - spawnedMonster.transform.position;
            lookDirection.y = 0;
            if (lookDirection != Vector3.zero)
            {
                spawnedMonster.transform.rotation = Quaternion.LookRotation(lookDirection);
            }
        }

        monsterPlaced = true;
        DisablePlaneVisualization();

        Debug.Log($"[ARPlacement] Monster manually placed at {position}");
    }
}
