using System;
using System.Collections;
using UnityEngine;

/// <summary>
/// Manages the player's real-time visual presence inside the 3D battle arena.
/// Renders the player's camera feed with background removal (MediaPipe mask or chroma cutout),
/// places the player in a face-to-face combat duel with the Boss, and adds dynamic combat VFX.
/// </summary>
public class PlayerPresenceManager : MonoBehaviour
{
    public static PlayerPresenceManager Instance { get; private set; }

    [Header("Camera & Cutout Setup")]
    public Material cutoutMaterial;
    public MeshRenderer playerQuadRenderer;
    public bool useWebCamInEditor = true;
    public int preferredCamWidth = 1280;
    public int preferredCamHeight = 720;
    public int preferredCamFPS = 30;

    [Header("Cutout Shader Settings")]
    public Color chromaKeyColor = new Color(0.1f, 0.8f, 0.2f, 1f);
    [Range(0f, 1f)] public float chromaThreshold = 0.35f;
    [Range(0.001f, 0.5f)] public float chromaSmoothing = 0.1f;
    public Color baseAuraColor = new Color(0.2f, 0.7f, 1.0f, 1.0f);
    public Color defendAuraColor = new Color(0.1f, 1.0f, 0.5f, 1.0f);
    public Color attackAuraColor = new Color(1.0f, 0.55f, 0.1f, 1.0f);
    public Color ultimateAuraColor = new Color(1.0f, 0.85f, 0.1f, 1.0f);
    [Range(0f, 3f)] public float auraIntensity = 1.2f;

    [Header("Face-Off Combat Arena Staging")]
    public Vector3 playerArenaPosition = new Vector3(-9.6f, 3.95f, -5.3f);
    public Vector3 playerArenaRotation = new Vector3(0f, 38f, 0f);
    public Vector3 playerQuadScale = new Vector3(1.4f, 1.9f, 1.0f);

    public Vector3 bossArenaPosition = new Vector3(-7.8f, 3.06f, -3.2f);
    public Vector3 bossArenaRotation = new Vector3(0f, 218f, 0f);

    public Vector3 cameraFaceOffPosition = new Vector3(-8.8f, 4.35f, -7.5f);
    public Vector3 cameraFaceOffRotation = new Vector3(12f, 15f, 0f);

    [Header("Combat VFX & Props")]
    public GameObject energyShield;
    public GameObject groundShadow;
    public ParticleSystem auraParticles;

    private WebCamTexture webCamTexture;
    private Texture2D fallbackSilhouetteTex;
    private Texture2D segmentationMaskTex;
    private Vector3 initialPlayerLocalPos;
    private Coroutine attackMotionRoutine;
    private Coroutine hitShakeRoutine;
    private Coroutine shieldFadeRoutine;

    void Awake()
    {
        if (Instance == null) Instance = this;
        else { Destroy(gameObject); return; }
    }

    void Start()
    {
        initialPlayerLocalPos = transform.position;
        SetupMaterialAndWebCam();
        AlignFaceOffStaging();
        UpdateAuraColor(baseAuraColor);
    }

    void OnDestroy()
    {
        if (webCamTexture != null && webCamTexture.isPlaying)
        {
            webCamTexture.Stop();
        }
    }

    #region WebCam & Material Setup
    private void SetupMaterialAndWebCam()
    {
        if (cutoutMaterial == null && playerQuadRenderer != null)
        {
            cutoutMaterial = playerQuadRenderer.sharedMaterial;
        }

        if (cutoutMaterial == null)
        {
            Shader cutoutShader = Shader.Find("Custom/PlayerLiveCutout");
            if (cutoutShader != null)
            {
                cutoutMaterial = new Material(cutoutShader);
                if (playerQuadRenderer != null) playerQuadRenderer.material = cutoutMaterial;
            }
        }

        // Initialize WebCam in Editor or standalone PC
        if (useWebCamInEditor && Application.isEditor)
        {
            if (WebCamTexture.devices.Length > 0)
            {
                string deviceName = WebCamTexture.devices[0].name;
                Debug.Log($"<color=#00E5FF>[PlayerPresence] Initializing WebCam: {deviceName}</color>");
                webCamTexture = new WebCamTexture(deviceName, preferredCamWidth, preferredCamHeight, preferredCamFPS);
                webCamTexture.Play();

                if (cutoutMaterial != null)
                {
                    cutoutMaterial.SetTexture("_MainTex", webCamTexture);
                    cutoutMaterial.SetFloat("_MirrorX", 1f);
                }
            }
            else
            {
                Debug.LogWarning("[PlayerPresence] No physical webcam detected. Generating fallback fighter silhouette.");
                CreateFallbackSilhouette();
            }
        }
        else if (webCamTexture == null)
        {
            CreateFallbackSilhouette();
        }
    }

    private void CreateFallbackSilhouette()
    {
        fallbackSilhouetteTex = new Texture2D(256, 512, TextureFormat.RGBA32, false);
        Color transparent = new Color(0, 0, 0, 0);
        Color fighterBody = new Color(0.12f, 0.45f, 0.85f, 0.95f);

        for (int y = 0; y < 512; y++)
        {
            for (int x = 0; x < 256; x++)
            {
                // Stylized fighter humanoid outline
                float nx = (x - 128f) / 128f;
                float ny = y / 512f;

                bool inHead = ny > 0.78f && ny < 0.94f && (nx * nx * 3.5f + (ny - 0.86f) * (ny - 0.86f) * 45f) < 0.25f;
                bool inTorso = ny >= 0.45f && ny <= 0.78f && Mathf.Abs(nx) < (0.35f - (ny - 0.45f) * 0.15f);
                bool inArms = ny >= 0.48f && ny <= 0.75f && Mathf.Abs(nx) < 0.55f;
                bool inLegs = ny < 0.45f && (Mathf.Abs(nx) > 0.06f && Mathf.Abs(nx) < 0.38f);

                if (inHead || inTorso || inArms || inLegs)
                {
                    fallbackSilhouetteTex.SetPixel(x, y, fighterBody);
                }
                else
                {
                    fallbackSilhouetteTex.SetPixel(x, y, transparent);
                }
            }
        }
        fallbackSilhouetteTex.Apply();

        if (cutoutMaterial != null)
        {
            cutoutMaterial.SetTexture("_MainTex", fallbackSilhouetteTex);
            cutoutMaterial.SetFloat("_UseMask", 0f);
            cutoutMaterial.SetColor("_ChromaColor", transparent);
        }
    }
    #endregion

    #region MediaPipe Segmentation Mask Integration
    /// <summary>
    /// Feed real-time MediaPipe selfie segmentation mask from mobile (Flutter/Native).
    /// Mask pixel value: 1.0 = Player body, 0.0 = Background.
    /// </summary>
    public void SetSegmentationMask(Texture2D maskTexture)
    {
        if (cutoutMaterial == null) return;
        cutoutMaterial.SetTexture("_MaskTex", maskTexture);
        cutoutMaterial.SetFloat("_UseMask", 1f);
    }

    /// <summary>
    /// Feed raw camera bytes and segmentation mask bytes from Flutter.
    /// </summary>
    public void SetPlayerCameraFrame(Texture2D cameraTexture)
    {
        if (cutoutMaterial == null) return;
        cutoutMaterial.SetTexture("_MainTex", cameraTexture);
    }
    #endregion

    #region Arena Staging & Alignment
    /// <summary>
    /// Staging: Places the Player and Boss facing directly against each other,
    /// with the Main Camera framed in an epic 3/4 over-the-shoulder fighting duel.
    /// </summary>
    [ContextMenu("Align Face-Off Staging")]
    public void AlignFaceOffStaging()
    {
        // 1. Position & Angle Player
        transform.position = playerArenaPosition;
        transform.eulerAngles = playerArenaRotation;
        transform.localScale = playerQuadScale;

        // 2. Position & Angle Boss (Warrok)
        GameObject boss = GameObject.Find("Warrok");
        if (boss != null)
        {
            boss.transform.position = bossArenaPosition;
            boss.transform.eulerAngles = bossArenaRotation;
        }

        // 3. Position & Angle Camera
        Camera mainCam = Camera.main;
        if (mainCam != null)
        {
            mainCam.transform.position = cameraFaceOffPosition;
            mainCam.transform.eulerAngles = cameraFaceOffRotation;
        }

        initialPlayerLocalPos = transform.position;
    }
    #endregion

    #region Combat Reactions & Animations
    public void OnPlayerPerformAction(PlayerActionType action)
    {
        switch (action)
        {
            case PlayerActionType.Punch:
            case PlayerActionType.Uppercut:
                TriggerAttackMotion(action == PlayerActionType.Uppercut);
                UpdateAuraColor(attackAuraColor);
                break;

            case PlayerActionType.Squat:
            case PlayerActionType.Plank:
                TriggerDefendShield();
                UpdateAuraColor(defendAuraColor);
                break;

            case PlayerActionType.HighKnee:
                UpdateAuraColor(new Color(0.7f, 0.2f, 1.0f)); // Purple focus aura
                break;

            case PlayerActionType.Ultimate:
                TriggerUltimateAwakening();
                break;
        }
    }

    public void OnPlayerDamaged(int damage)
    {
        if (hitShakeRoutine != null) StopCoroutine(hitShakeRoutine);
        hitShakeRoutine = StartCoroutine(HitShakeRoutine());
    }

    private void TriggerAttackMotion(bool isUppercut)
    {
        if (attackMotionRoutine != null) StopCoroutine(attackMotionRoutine);
        attackMotionRoutine = StartCoroutine(AttackMotionRoutine(isUppercut));
    }

    private IEnumerator AttackMotionRoutine(bool isUppercut)
    {
        Vector3 forwardDir = transform.forward;
        Vector3 peakPos = initialPlayerLocalPos + forwardDir * 0.45f + (isUppercut ? Vector3.up * 0.2f : Vector3.zero);

        float elapsed = 0f;
        float duration = 0.12f;

        // Lunge forward
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            transform.position = Vector3.Lerp(initialPlayerLocalPos, peakPos, elapsed / duration);
            yield return null;
        }

        // Return to stance
        elapsed = 0f;
        float returnDuration = 0.22f;
        while (elapsed < returnDuration)
        {
            elapsed += Time.deltaTime;
            transform.position = Vector3.Lerp(peakPos, initialPlayerLocalPos, elapsed / returnDuration);
            yield return null;
        }

        transform.position = initialPlayerLocalPos;
        yield return new WaitForSeconds(0.4f);
        UpdateAuraColor(baseAuraColor);
    }

    private void TriggerDefendShield()
    {
        if (energyShield != null)
        {
            energyShield.SetActive(true);
            if (shieldFadeRoutine != null) StopCoroutine(shieldFadeRoutine);
            shieldFadeRoutine = StartCoroutine(ShieldFadeRoutine());
        }
    }

    private IEnumerator ShieldFadeRoutine()
    {
        yield return new WaitForSeconds(2.5f);
        if (energyShield != null) energyShield.SetActive(false);
        UpdateAuraColor(baseAuraColor);
    }

    private void TriggerUltimateAwakening()
    {
        UpdateAuraColor(ultimateAuraColor);
        if (cutoutMaterial != null)
        {
            cutoutMaterial.SetFloat("_AuraIntensity", 2.5f);
        }

        // Start slight breathing hover
        StartCoroutine(UltimateGlowRoutine());
    }

    private IEnumerator UltimateGlowRoutine()
    {
        yield return new WaitForSeconds(3.5f);
        if (cutoutMaterial != null)
        {
            cutoutMaterial.SetFloat("_AuraIntensity", auraIntensity);
        }
        UpdateAuraColor(baseAuraColor);
    }

    private IEnumerator HitShakeRoutine()
    {
        if (cutoutMaterial != null) cutoutMaterial.SetFloat("_HitFlash", 0.75f);

        float elapsed = 0f;
        float shakeDuration = 0.25f;

        while (elapsed < shakeDuration)
        {
            elapsed += Time.deltaTime;
            float offsetX = UnityEngine.Random.Range(-0.06f, 0.06f);
            float offsetY = UnityEngine.Random.Range(-0.04f, 0.04f);
            transform.position = initialPlayerLocalPos + new Vector3(offsetX, offsetY, 0f);
            yield return null;
        }

        transform.position = initialPlayerLocalPos;
        if (cutoutMaterial != null) cutoutMaterial.SetFloat("_HitFlash", 0f);
    }

    public void UpdateAuraColor(Color color)
    {
        if (cutoutMaterial != null)
        {
            cutoutMaterial.SetColor("_AuraColor", color);
            cutoutMaterial.SetFloat("_AuraIntensity", auraIntensity);
        }
    }
    #endregion
}
