using System;
using System.Collections;
using UnityEngine;

public enum PlayerActionType
{
    Punch,
    Uppercut,
    Squat,
    Plank,
    HighKnee,
    Ultimate
}

public class BattleManager : MonoBehaviour
{
    public static BattleManager Instance { get; private set; }

    [Header("Boss Stats")]
    public string bossName = "Dragon of Laziness";
    public int bossMaxHp = 10000;
    public int bossCurrentHp = 6450;
    public int damageToStagger = 800;
    public int accumulatedDamage = 0;
    public bool isBossDown = false;
    public bool isBossDead = false;
    public float downDuration = 6f;

    [Header("Player Stats")]
    public string playerName = "You";
    public int playerMaxHp = 500;
    public int playerCurrentHp = 430;
    public int playerEnergyBlocks = 4;
    public float playerEnergyPercent = 72f;
    public float ultimateCharge = 72f; // 0 to 100%
    public int playerLevel = 12;
    public int playerExp = 650;
    public int playerMaxExp = 900;
    public int lastExpGained = 30;

    [Header("Player Defense / Buff States")]
    public bool isDodging = false;
    public bool isDefending = false;
    public float dodgeDuration = 2.5f;
    public float defendDuration = 3.5f;
    private Coroutine dodgeRoutine;
    private Coroutine defendRoutine;

    [Header("Boss Attack AI Loop")]
    public bool autoBossAttack = true;
    public float minAttackInterval = 5f;
    public float maxAttackInterval = 8f;
    public float attackWarningTime = 1.5f;
    public bool isBossAttacking = false;
    public bool isWarningActive = false;
    private Coroutine bossAiRoutine;

    [Header("Battle Timer")]
    public float battleTimeSeconds = 165f; // 2:45
    public bool isBattleRunning = true;

    [Header("References")]
    public MonsterController monster;
    public BattleUIManager uiManager;

    void Awake()
    {
        if (Instance == null) Instance = this;
        else Destroy(gameObject);
    }

    void Start()
    {
        if (monster == null) monster = FindObjectOfType<MonsterController>();
        if (uiManager == null) uiManager = FindObjectOfType<BattleUIManager>();

        if (autoBossAttack)
        {
            bossAiRoutine = StartCoroutine(BossAttackLoop());
        }

        UpdateAllUI();
        Debug.Log("<color=#4CAF50>[BattleManager] Initialized successfully.</color>");
    }

    void Update()
    {
        // Update battle timer
        if (isBattleRunning && !isBossDead && playerCurrentHp > 0)
        {
            battleTimeSeconds += Time.deltaTime;
            uiManager?.UpdateTimer(battleTimeSeconds);
        }

        // Keyboard hotkeys for instant Unity Editor testing
        HandleKeyboardInput();
    }

    private void HandleKeyboardInput()
    {
#if ENABLE_INPUT_SYSTEM
        var kb = UnityEngine.InputSystem.Keyboard.current;
        if (kb != null)
        {
            if (kb.digit1Key.wasPressedThisFrame || kb.numpad1Key.wasPressedThisFrame) ExecuteAction(PlayerActionType.Punch);
            if (kb.digit2Key.wasPressedThisFrame || kb.numpad2Key.wasPressedThisFrame) ExecuteAction(PlayerActionType.Uppercut);
            if (kb.digit3Key.wasPressedThisFrame || kb.numpad3Key.wasPressedThisFrame) ExecuteAction(PlayerActionType.Squat);
            if (kb.digit4Key.wasPressedThisFrame || kb.numpad4Key.wasPressedThisFrame) ExecuteAction(PlayerActionType.Plank);
            if (kb.digit5Key.wasPressedThisFrame || kb.numpad5Key.wasPressedThisFrame) ExecuteAction(PlayerActionType.HighKnee);
            if (kb.spaceKey.wasPressedThisFrame) ExecuteAction(PlayerActionType.Ultimate);
        }
#elif ENABLE_LEGACY_INPUT_MANAGER
        if (Input.GetKeyDown(KeyCode.Alpha1)) ExecuteAction(PlayerActionType.Punch);
        if (Input.GetKeyDown(KeyCode.Alpha2)) ExecuteAction(PlayerActionType.Uppercut);
        if (Input.GetKeyDown(KeyCode.Alpha3)) ExecuteAction(PlayerActionType.Squat);
        if (Input.GetKeyDown(KeyCode.Alpha4)) ExecuteAction(PlayerActionType.Plank);
        if (Input.GetKeyDown(KeyCode.Alpha5)) ExecuteAction(PlayerActionType.HighKnee);
        if (Input.GetKeyDown(KeyCode.Space)) ExecuteAction(PlayerActionType.Ultimate);
#endif
    }

    public void ExecuteAction(PlayerActionType action)
    {
        if (isBossDead || playerCurrentHp <= 0) return;

        switch (action)
        {
            case PlayerActionType.Punch:
                PerformPunch();
                break;
            case PlayerActionType.Uppercut:
                PerformUppercut();
                break;
            case PlayerActionType.Squat:
                PerformSquat();
                break;
            case PlayerActionType.Plank:
                PerformPlank();
                break;
            case PlayerActionType.HighKnee:
                PerformHighKnee();
                break;
            case PlayerActionType.Ultimate:
                PerformUltimate();
                break;
        }

        PlayerPresenceManager.Instance?.OnPlayerPerformAction(action);
        UpdateAllUI();
    }

    // 1. PUNCH (โจมตีพื้นฐาน)
    private void PerformPunch()
    {
        int baseDamage = 150;
        if (isBossDown) baseDamage = (int)(baseDamage * 1.5f); // Bonus damage when boss is down

        DealDamageToBoss(baseDamage, false);
        AddUltimateCharge(5f);
        AddExp(15);

        uiManager?.ShowCombatFeedback($"-{baseDamage} PUNCH", Color.cyan);
        uiManager?.HighlightCard(PlayerActionType.Punch);
        FlutterBridge.SendMessage("PLAYER_ACTION_COMPLETED", "{\"action\":\"PUNCH\",\"damage\":" + baseDamage + "}");
    }

    // 2. UPPERCUT (คริติคอลฮิต)
    private void PerformUppercut()
    {
        int critDamage = 400;
        if (isBossDown) critDamage = (int)(critDamage * 1.5f);

        DealDamageToBoss(critDamage, true);
        AddUltimateCharge(10f);
        AddExp(30);

        CameraShake.Instance?.Shake(0.25f, 0.15f);
        uiManager?.ShowCombatFeedback($"💥 CRITICAL -{critDamage}!", Color.yellow);
        uiManager?.HighlightCard(PlayerActionType.Uppercut);
        FlutterBridge.SendMessage("PLAYER_ACTION_COMPLETED", "{\"action\":\"UPPERCUT\",\"damage\":" + critDamage + "}");
    }

    // 3. SQUAT (หลบการโจมตี)
    private void PerformSquat()
    {
        if (dodgeRoutine != null) StopCoroutine(dodgeRoutine);
        dodgeRoutine = StartCoroutine(DodgeStanceRoutine());

        uiManager?.ShowCombatFeedback("💨 DODGE STANCE ACTIVE!", Color.green);
        uiManager?.HighlightCard(PlayerActionType.Squat);
        FlutterBridge.SendMessage("PLAYER_ACTION_COMPLETED", "{\"action\":\"SQUAT\",\"buff\":\"DODGE\"}");
    }

    private IEnumerator DodgeStanceRoutine()
    {
        isDodging = true;
        yield return new WaitForSeconds(dodgeDuration);
        isDodging = false;
    }

    // 4. PLANK (ตั้งโล่ป้องกัน)
    private void PerformPlank()
    {
        if (defendRoutine != null) StopCoroutine(defendRoutine);
        defendRoutine = StartCoroutine(DefendStanceRoutine());

        uiManager?.ShowCombatFeedback("🛡️ SHIELD DEPLOYED!", new Color(0.2f, 0.6f, 1f));
        uiManager?.HighlightCard(PlayerActionType.Plank);
        FlutterBridge.SendMessage("PLAYER_ACTION_COMPLETED", "{\"action\":\"PLANK\",\"buff\":\"SHIELD\"}");
    }

    private IEnumerator DefendStanceRoutine()
    {
        isDefending = true;
        yield return new WaitForSeconds(defendDuration);
        isDefending = false;
    }

    // 5. HIGH KNEE (ชาร์จพลังอัลติเมท)
    private void PerformHighKnee()
    {
        AddUltimateCharge(15f);
        AddExp(20);

        uiManager?.ShowCombatFeedback("⚡ ULTIMATE CHARGING +15%!", new Color(1f, 0.8f, 0.2f));
        uiManager?.HighlightCard(PlayerActionType.HighKnee);
        FlutterBridge.SendMessage("PLAYER_ACTION_COMPLETED", "{\"action\":\"HIGH_KNEE\",\"charge\":15}");
    }

    // 6. ULTIMATE ATTACK
    private void PerformUltimate()
    {
        if (ultimateCharge < 100f)
        {
            uiManager?.ShowCombatFeedback($"Ultimate only at {Mathf.RoundToInt(ultimateCharge)}%!", Color.red);
            return;
        }

        ultimateCharge = 0f;
        int ultDamage = 1500;
        DealDamageToBoss(ultDamage, true);
        AddExp(100);

        CameraShake.Instance?.Shake(0.5f, 0.3f);
        uiManager?.ShowCombatFeedback("🔥 ULTIMATE DRAGON STRIKE -1500! 🔥", Color.magenta);
        FlutterBridge.SendMessage("PLAYER_ACTION_COMPLETED", "{\"action\":\"ULTIMATE\",\"damage\":" + ultDamage + "}");
    }

    // Deal Damage to Boss
    private void DealDamageToBoss(int damage, bool isCrit)
    {
        bossCurrentHp = Mathf.Max(0, bossCurrentHp - damage);
        accumulatedDamage += damage;

        // Play boss hit animation via MonsterController
        if (monster != null)
        {
            monster.TakeDamage(damage, isCrit);
        }

        // Check Stagger / Down condition
        if (accumulatedDamage >= damageToStagger && !isBossDown && bossCurrentHp > 0)
        {
            StartCoroutine(BossDownRoutine());
        }

        // Check Death
        if (bossCurrentHp <= 0)
        {
            TriggerBossDeath();
        }
    }

    private IEnumerator BossDownRoutine()
    {
        isBossDown = true;
        accumulatedDamage = 0;

        uiManager?.ShowAnnouncement("⚡ BOSS DOWN! ATTACK FREELY! ⚡", Color.yellow);
        if (monster != null)
        {
            monster.EnterStaggerFromBattleManager();
        }
        FlutterBridge.SendMessage("BOSS_STAGGERED", "{\"duration\":" + downDuration + "}");

        yield return new WaitForSeconds(downDuration);

        isBossDown = false;
        if (monster != null && !isBossDead)
        {
            monster.ExitStaggerFromBattleManager();
        }
        uiManager?.ShowAnnouncement("Boss has recovered!", Color.white);
        FlutterBridge.SendMessage("BOSS_RECOVERED", "{}");
    }

    private void TriggerBossDeath()
    {
        isBossDead = true;
        isBattleRunning = false;
        if (bossAiRoutine != null) StopCoroutine(bossAiRoutine);

        if (monster != null) monster.DieFromBattleManager();

        uiManager?.ShowVictoryScreen();
        FlutterBridge.SendMessage("BATTLE_VICTORY", "{\"boss\":\"" + bossName + "\"}");
        Debug.Log("<color=#FFD700>[BattleManager] VICTORY! Boss Defeated.</color>");
    }

    // Boss Attack AI Loop
    private IEnumerator BossAttackLoop()
    {
        while (!isBossDead && playerCurrentHp > 0)
        {
            float waitTime = UnityEngine.Random.Range(minAttackInterval, maxAttackInterval);
            yield return new WaitForSeconds(waitTime);

            if (isBossDead || isBossDown) continue;

            // Step 1: Warning phase
            isWarningActive = true;
            uiManager?.ShowBossWarning("⚠️ BOSS ATTACK INCOMING! SQUAT OR PLANK! ⚠️");
            FlutterBridge.SendMessage("BOSS_ATTACK_WARNING", "{\"warningTime\":" + attackWarningTime + "}");

            yield return new WaitForSeconds(attackWarningTime);
            isWarningActive = false;
            uiManager?.HideBossWarning();

            if (isBossDead || isBossDown) continue;

            // Step 2: Strike phase
            if (monster != null)
            {
                monster.PlayAttackAnimation();
            }

            yield return new WaitForSeconds(0.4f); // Animation impact delay

            // Step 3: Resolve damage based on player defense
            ResolveBossAttackDamage();
            UpdateAllUI();
        }
    }

    private void ResolveBossAttackDamage()
    {
        int rawBossDamage = 60;

        if (isDodging)
        {
            uiManager?.ShowCombatFeedback("✨ DODGE SUCCESS! 0 DAMAGE! ✨", Color.green);
            FlutterBridge.SendMessage("PLAYER_DODGE_SUCCESS", "{}");
            return;
        }

        if (isDefending)
        {
            int reducedDamage = Mathf.RoundToInt(rawBossDamage * 0.2f); // 80% blocked
            playerCurrentHp = Mathf.Max(0, playerCurrentHp - reducedDamage);
            uiManager?.ShowCombatFeedback($"🛡️ BLOCKED! -{reducedDamage} HP", Color.cyan);
            FlutterBridge.SendMessage("PLAYER_DAMAGED", "{\"damage\":" + reducedDamage + ",\"currentHp\":" + playerCurrentHp + "}");
            return;
        }

        // Direct Hit
        playerCurrentHp = Mathf.Max(0, playerCurrentHp - rawBossDamage);
        CameraShake.Instance?.Shake(0.3f, 0.2f);
        PlayerPresenceManager.Instance?.OnPlayerDamaged(rawBossDamage);
        uiManager?.ShowCombatFeedback($"💥 HIT BY BOSS! -{rawBossDamage} HP", Color.red);
        FlutterBridge.SendMessage("PLAYER_DAMAGED", "{\"damage\":" + rawBossDamage + ",\"currentHp\":" + playerCurrentHp + "}");

        if (playerCurrentHp <= 0)
        {
            isBattleRunning = false;
            uiManager?.ShowDefeatScreen();
            FlutterBridge.SendMessage("BATTLE_DEFEAT", "{}");
        }
    }

    private void AddUltimateCharge(float amount)
    {
        ultimateCharge = Mathf.Min(100f, ultimateCharge + amount);
    }

    private void AddExp(int amount)
    {
        lastExpGained = amount;
        playerExp += amount;
        if (playerExp >= playerMaxExp)
        {
            playerLevel++;
            playerExp -= playerMaxExp;
            playerMaxExp = (int)(playerMaxExp * 1.25f);
            uiManager?.ShowAnnouncement($"🎉 LEVEL UP! LV {playerLevel}!", Color.yellow);
        }
    }

    public void UpdateAllUI()
    {
        if (uiManager != null)
        {
            uiManager.UpdateBossUI(bossName, bossCurrentHp, bossMaxHp);
            uiManager.UpdatePlayerUI(playerName, playerCurrentHp, playerMaxHp, playerEnergyBlocks, playerEnergyPercent, ultimateCharge, playerLevel, playerExp, playerMaxExp, lastExpGained);
        }
    }
}
