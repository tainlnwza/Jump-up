using UnityEngine;

public class MonsterController : MonoBehaviour
{
    [Header("Components")]
    private Animator animator;
    private AudioSource audioSource;

    [Header("Stats")]
    public int maxHealth = 10000;
    public int currentHealth = 6450;
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

    void Start()
    {
        animator = GetComponent<Animator>();
        audioSource = GetComponent<AudioSource>();

        if (BattleManager.Instance != null)
        {
            maxHealth = BattleManager.Instance.bossMaxHp;
            currentHealth = BattleManager.Instance.bossCurrentHp;
        }

        UpdateHpBlendTree();
        SendMessageToFlutter("UNITY_READY", "{}");
    }

    void Update()
    {
        // Smoothly face the main camera
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

    // Called when taking damage (from BattleManager or Flutter)
    public void TakeDamage(int damage, bool isCritical = false)
    {
        if (isDead) return;

        currentHealth = Mathf.Max(0, currentHealth - damage);
        UpdateHpBlendTree();

        // Play hit animation if not staggered
        if (!isStaggered && animator != null)
        {
            animator.SetTrigger("Hit");
        }

        // Spawn hit VFX
        Vector3 hitPosition = transform.position + Vector3.up * 1.5f + Random.insideUnitSphere * 0.3f;
        GameObject effect = isCritical ? criticalHitEffectPrefab : hitEffectPrefab;
        if (effect != null)
        {
            GameObject vfx = Instantiate(effect, hitPosition, Quaternion.identity);
            Destroy(vfx, 2f);
        }

        // Spawn floating damage number
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

        // Notify Flutter
        string json = $"{{\"damage\":{damage},\"currentHp\":{currentHealth},\"isCritical\":{isCritical.ToString().ToLower()}}}";
        SendMessageToFlutter("DAMAGE_DEALT", json);
    }

    private void UpdateHpBlendTree()
    {
        if (animator != null && maxHealth > 0)
        {
            float ratio = (float)currentHealth / maxHealth;
            animator.SetFloat("HpPercent", ratio);
        }
    }

    public void PlayAttackAnimation()
    {
        if (isDead || isStaggered) return;
        if (animator != null)
        {
            animator.SetTrigger("Attack");
        }
        SendMessageToFlutter("ANIMATION_STARTED", "{\"animation\":\"attack\"}");
    }

    public void EnterStaggerFromBattleManager()
    {
        if (isDead) return;
        isStaggered = true;
        if (animator != null)
        {
            animator.SetTrigger("Stagger");
        }
    }

    public void ExitStaggerFromBattleManager()
    {
        if (isDead) return;
        isStaggered = false;
        if (animator != null)
        {
            animator.SetTrigger("StaggerEnd");
        }
    }

    public void DieFromBattleManager()
    {
        if (isDead) return;
        isDead = true;

        if (animator != null)
        {
            animator.SetTrigger("Death");
        }

        if (deathEffectPrefab != null)
        {
            GameObject deathVfx = Instantiate(deathEffectPrefab, transform.position, Quaternion.identity);
            Destroy(deathVfx, 5f);
        }

        if (audioSource != null && deathSound != null)
        {
            audioSource.PlayOneShot(deathSound);
        }

        // Slow motion finish
        Time.timeScale = 0.3f;
        Invoke(nameof(ResetTimeScale), 0.6f);

        SendMessageToFlutter("MONSTER_DEFEATED", "{}");
    }

    void ResetTimeScale()
    {
        Time.timeScale = 1f;
    }

    void SendMessageToFlutter(string messageType, string data)
    {
        FlutterBridge.SendMessage(messageType, data);
    }

    // Animation Event callbacks
    public void OnAttackHit()
    {
        SendMessageToFlutter("ATTACK_HIT", "{}");
    }

    public void OnAttackComplete()
    {
        SendMessageToFlutter("ANIMATION_COMPLETE", "{\"animation\":\"attack\"}");
    }
}
