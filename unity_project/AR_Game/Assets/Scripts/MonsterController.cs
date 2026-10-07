// Unity C# Script: MonsterController.cs
// Location: unity_project/Assets/Scripts/MonsterController.cs

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
    public GameObject damageNumberPrefab;

    [Header("Audio")]
    public AudioClip hitSound;
    public AudioClip criticalHitSound;
    public AudioClip deathSound;
    private AudioSource audioSource;

    void Start()
    {
        animator = GetComponent<Animator>();
        audioSource = GetComponent<AudioSource>();
        currentHealth = maxHealth;

        // Notify Flutter that Unity is ready
        SendMessageToFlutter("UNITY_READY", "{}");
    }

    void Update()
    {
        // Always face camera
        if (Camera.main != null)
        {
            Vector3 lookDirection = Camera.main.transform.position - transform.position;
            lookDirection.y = 0; // Keep upright
            if (lookDirection != Vector3.zero)
            {
                transform.rotation = Quaternion.Slerp(
                    transform.rotation,
                    Quaternion.LookRotation(lookDirection),
                    Time.deltaTime * 5f
                );
            }
        }
    }

    // Called from Flutter via FlutterBridge
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

        // Spawn VFX at hit position
        Vector3 hitPosition = transform.position + Vector3.up * 1.5f + Random.insideUnitSphere * 0.3f;
        GameObject effect = isCritical ? criticalHitEffectPrefab : hitEffectPrefab;
        if (effect != null)
        {
            GameObject vfx = Instantiate(effect, hitPosition, Quaternion.identity);
            Destroy(vfx, 2f);
        }

        // Spawn damage number
        if (damageNumberPrefab != null)
        {
            GameObject dmgNum = Instantiate(damageNumberPrefab, hitPosition, Quaternion.identity);
            DamageNumber dmgScript = dmgNum.GetComponent<DamageNumber>();
            if (dmgScript != null)
            {
                dmgScript.Initialize(damage, isCritical);
            }
            Destroy(dmgNum, 2f);
        }

        // Play sound
        if (audioSource != null)
        {
            audioSource.PlayOneShot(isCritical ? criticalHitSound : hitSound);
        }

        // Screen shake for critical hits
        if (isCritical)
        {
            CameraShake.Instance?.Shake(0.2f, 0.1f);
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
        string json = $"{{\"damage\":{damage},\"currentHp\":{currentHealth},\"isCritical\":{isCritical.ToString().ToLower()}}}";
        SendMessageToFlutter("DAMAGE_DEALT", json);
    }

    public void PlayAttackAnimation()
    {
        if (isDead || isStaggered) return;
        animator.SetTrigger("Attack");
        SendMessageToFlutter("ANIMATION_STARTED", "{\"animation\":\"attack\"}");
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
        if (isDead) return;
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
            GameObject deathVfx = Instantiate(deathEffectPrefab, transform.position, Quaternion.identity);
            Destroy(deathVfx, 5f);
        }

        // Play death sound
        if (audioSource != null && deathSound != null)
        {
            audioSource.PlayOneShot(deathSound);
        }

        // Slow motion effect
        Time.timeScale = 0.3f;
        Invoke("ResetTimeScale", 0.5f);

        SendMessageToFlutter("MONSTER_DEFEATED", "{}");

        // Destroy after animation (3 seconds)
        Destroy(gameObject, 3.5f);
    }

    void ResetTimeScale()
    {
        Time.timeScale = 1f;
    }

    void SendMessageToFlutter(string messageType, string data)
    {
        FlutterBridge.SendMessage(messageType, data);
    }

    // Animation Events (called from animation timeline)
    public void OnAttackHit()
    {
        SendMessageToFlutter("ATTACK_HIT", "");
    }

    public void OnAttackComplete()
    {
        SendMessageToFlutter("ANIMATION_COMPLETE", "{\"animation\":\"attack\"}");
    }
}
