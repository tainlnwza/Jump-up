#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
using UnityEngine.UI;

public static class BattleSystemSetup
{
    [MenuItem("Tools/Setup Full Phase 2 Battle System", false, 10)]
    public static void SetupFullBattleSystem()
    {
        Debug.Log("<color=#2196F3><b>[BattleSetup]</b> Starting Full Battle System Setup...</color>");

        // Step 1: Configure Monster Animator Controller
        SetupAnimatorController();

        // Step 2: Configure Monster GameObject in Scene
        GameObject monsterGo = SetupMonsterGameObject();

        // Step 3: Create or Configure BattleManager & FlutterBridge
        GameObject managerGo = SetupBattleManager(monsterGo);

        // Step 4: Build Canvas UI
        BattleUIManager uiManager = SetupBattleUI();

        // Step 4b: Setup Real-Time Player Presence & Face-Off Staging
        SetupPlayerPresence();

        // Step 5: Wire up references
        BattleManager bm = managerGo.GetComponent<BattleManager>();
        bm.monster = monsterGo.GetComponent<MonsterController>();
        bm.uiManager = uiManager;

        // Step 6: Save Scene
        UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(
            UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene()
        );
        UnityEditor.SceneManagement.EditorSceneManager.SaveOpenScenes();

        Debug.Log("<color=#4CAF50><b>[BattleSetup]</b> Full Battle System & UI Setup Complete!</color>");
    }

    private static void SetupAnimatorController()
    {
        string controllerPath = "Assets/monster/monster.controller";
        AnimatorController controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(controllerPath);

        if (controller == null)
        {
            controller = AnimatorController.CreateAnimatorControllerAtPath(controllerPath);
        }

        // Add Parameters
        AddParameterIfNotExists(controller, "Hit", AnimatorControllerParameterType.Trigger);
        AddParameterIfNotExists(controller, "Attack", AnimatorControllerParameterType.Trigger);
        AddParameterIfNotExists(controller, "Stagger", AnimatorControllerParameterType.Trigger);
        AddParameterIfNotExists(controller, "StaggerEnd", AnimatorControllerParameterType.Trigger);
        AddParameterIfNotExists(controller, "Death", AnimatorControllerParameterType.Trigger);
        AddParameterIfNotExists(controller, "HpPercent", AnimatorControllerParameterType.Float);

        // Load Clips
        AnimationClip idleClip = LoadFirstClipFromFBX("Assets/monster/idle.fbx");
        AnimationClip atkClip = LoadFirstClipFromFBX("Assets/monster/atk.fbx");
        AnimationClip dmgInClip = LoadFirstClipFromFBX("Assets/monster/damage in.fbx");
        AnimationClip dmgOutClip = LoadFirstClipFromFBX("Assets/monster/damage out.fbx");
        AnimationClip downClip = LoadFirstClipFromFBX("Assets/monster/down.fbx");
        AnimationClip dieClip = LoadFirstClipFromFBX("Assets/monster/die.fbx");

        AnimatorStateMachine rootStateMachine = controller.layers[0].stateMachine;

        // Clear existing states to ensure clean setup
        foreach (var childState in rootStateMachine.states)
        {
            rootStateMachine.RemoveState(childState.state);
        }

        // Create States
        AnimatorState idleState = rootStateMachine.AddState("Idle", new Vector3(250, 100, 0));
        idleState.motion = idleClip;
        rootStateMachine.defaultState = idleState;

        AnimatorState attackState = rootStateMachine.AddState("Attack", new Vector3(250, -50, 0));
        attackState.motion = atkClip;

        AnimatorState dmgInState = rootStateMachine.AddState("DamageIn", new Vector3(500, 50, 0));
        dmgInState.motion = dmgInClip;

        AnimatorState dmgOutState = rootStateMachine.AddState("DamageOut", new Vector3(500, 150, 0));
        dmgOutState.motion = dmgOutClip;

        AnimatorState downState = rootStateMachine.AddState("Down", new Vector3(250, 250, 0));
        downState.motion = downClip;

        AnimatorState deathState = rootStateMachine.AddState("Death", new Vector3(50, 300, 0));
        deathState.motion = dieClip;

        // Transitions: Idle <-> Attack
        var idleToAtk = idleState.AddTransition(attackState);
        idleToAtk.AddCondition(AnimatorConditionMode.If, 0, "Attack");
        idleToAtk.hasExitTime = false;
        idleToAtk.duration = 0.1f;

        var atkToIdle = attackState.AddTransition(idleState);
        atkToIdle.hasExitTime = true;
        atkToIdle.exitTime = 0.85f;
        atkToIdle.duration = 0.15f;

        // Transitions: Idle -> DamageIn -> DamageOut -> Idle
        var idleToDmgIn = idleState.AddTransition(dmgInState);
        idleToDmgIn.AddCondition(AnimatorConditionMode.If, 0, "Hit");
        idleToDmgIn.hasExitTime = false;
        idleToDmgIn.duration = 0.05f;

        var dmgInToOut = dmgInState.AddTransition(dmgOutState);
        dmgInToOut.hasExitTime = true;
        dmgInToOut.exitTime = 0.9f;
        dmgInToOut.duration = 0.1f;

        var dmgOutToIdle = dmgOutState.AddTransition(idleState);
        dmgOutToIdle.hasExitTime = true;
        dmgOutToIdle.exitTime = 0.9f;
        dmgOutToIdle.duration = 0.15f;

        // Transitions: Idle <-> Down
        var idleToDown = idleState.AddTransition(downState);
        idleToDown.AddCondition(AnimatorConditionMode.If, 0, "Stagger");
        idleToDown.hasExitTime = false;
        idleToDown.duration = 0.1f;

        var downToIdle = downState.AddTransition(idleState);
        downToIdle.AddCondition(AnimatorConditionMode.If, 0, "StaggerEnd");
        downToIdle.hasExitTime = false;
        downToIdle.duration = 0.2f;

        // AnyState -> Death
        var anyToDeath = rootStateMachine.AddAnyStateTransition(deathState);
        anyToDeath.AddCondition(AnimatorConditionMode.If, 0, "Death");
        anyToDeath.hasExitTime = false;
        anyToDeath.duration = 0.1f;

        EditorUtility.SetDirty(controller);
        AssetDatabase.SaveAssets();
        Debug.Log("[BattleSetup] Animator Controller configured with 6 states and transitions.");
    }

    private static void AddParameterIfNotExists(AnimatorController controller, string name, AnimatorControllerParameterType type)
    {
        foreach (var p in controller.parameters)
        {
            if (p.name == name) return;
        }
        controller.AddParameter(name, type);
    }

    private static AnimationClip LoadFirstClipFromFBX(string fbxPath)
    {
        Object[] assets = AssetDatabase.LoadAllAssetsAtPath(fbxPath);
        foreach (var a in assets)
        {
            if (a is AnimationClip clip && !clip.name.StartsWith("__preview__"))
            {
                return clip;
            }
        }
        return null;
    }

    private static GameObject SetupMonsterGameObject()
    {
        GameObject warrok = GameObject.Find("Warrok");
        if (warrok == null)
        {
            warrok = new GameObject("Warrok");
        }

        // Add Animator
        Animator anim = warrok.GetComponent<Animator>();
        if (anim == null) anim = warrok.AddComponent<Animator>();
        anim.runtimeAnimatorController = AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>("Assets/monster/monster.controller");

        // Try load avatar from idle.fbx
        Avatar avatar = AssetDatabase.LoadAssetAtPath<Avatar>("Assets/monster/idle.fbx");
        if (avatar != null) anim.avatar = avatar;

        // Add MonsterController
        MonsterController mc = warrok.GetComponent<MonsterController>();
        if (mc == null) mc = warrok.AddComponent<MonsterController>();

        // Add CapsuleCollider
        CapsuleCollider col = warrok.GetComponent<CapsuleCollider>();
        if (col == null) col = warrok.AddComponent<CapsuleCollider>();
        col.center = new Vector3(0, 1.1f, 0);
        col.radius = 0.8f;
        col.height = 2.4f;

        // Add AudioSource
        AudioSource audio = warrok.GetComponent<AudioSource>();
        if (audio == null) audio = warrok.AddComponent<AudioSource>();
        audio.playOnAwake = false;

        Debug.Log("[BattleSetup] Monster GameObject (Warrok) components configured.");
        return warrok;
    }

    private static GameObject SetupBattleManager(GameObject monsterGo)
    {
        GameObject bmGo = GameObject.Find("BattleManager");
        if (bmGo == null) bmGo = new GameObject("BattleManager");

        BattleManager bm = bmGo.GetComponent<BattleManager>();
        if (bm == null) bm = bmGo.AddComponent<BattleManager>();

        FlutterBridge fb = bmGo.GetComponent<FlutterBridge>();
        if (fb == null) fb = bmGo.AddComponent<FlutterBridge>();

        CameraShake shake = Camera.main != null ? Camera.main.GetComponent<CameraShake>() : null;
        if (shake == null && Camera.main != null) Camera.main.gameObject.AddComponent<CameraShake>();

        return bmGo;
    }

    private static BattleUIManager SetupBattleUI()
    {
        GameObject canvasGo = GameObject.Find("BattleCanvas");
        if (canvasGo != null) Object.DestroyImmediate(canvasGo);

        canvasGo = new GameObject("BattleCanvas");
        Canvas canvas = canvasGo.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;

        CanvasScaler scaler = canvasGo.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);
        scaler.matchWidthOrHeight = 0.5f;

        canvasGo.AddComponent<GraphicRaycaster>();
        BattleUIManager uiManager = canvasGo.AddComponent<BattleUIManager>();

        Font defaultFont = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        if (defaultFont == null) defaultFont = Resources.GetBuiltinResource<Font>("Arial.ttf");

        // ------------------ TOP BAR (BOSS UI) ------------------
        GameObject topBar = CreateUIObject("TopBarPanel", canvasGo.transform);
        SetRect(topBar, new Vector2(0, 1), new Vector2(1, 1), new Vector2(0.5f, 1), new Vector2(0, 0), new Vector2(0, 130));
        Image topBg = topBar.AddComponent<Image>();
        topBg.color = new Color(0.04f, 0.08f, 0.16f, 0.92f); // Dark translucent blue

        // Top purple/blue neon line
        GameObject neonLine = CreateUIObject("NeonTopLine", topBar.transform);
        SetRect(neonLine, new Vector2(0, 1), new Vector2(1, 1), new Vector2(0.5f, 1), new Vector2(0, -2), new Vector2(0, 4));
        neonLine.AddComponent<Image>().color = new Color(0.6f, 0.3f, 1f, 1f);

        // Boss Title text container
        GameObject bossTitleGo = CreateUIObject("BossTitle", topBar.transform);
        SetRect(bossTitleGo, new Vector2(0.5f, 1), new Vector2(0.5f, 1), new Vector2(0.5f, 1), new Vector2(0, -18), new Vector2(600, 45));
        Text titleText = bossTitleGo.AddComponent<Text>();
        titleText.font = defaultFont;
        titleText.text = "👹 Season Boss - Dragon of Laziness 🔥";
        titleText.fontSize = 24;
        titleText.fontStyle = FontStyle.Bold;
        titleText.alignment = TextAnchor.MiddleCenter;
        titleText.color = Color.white;
        uiManager.bossNameText = titleText;

        // Boss HP Slider
        GameObject bossHpBarGo = CreateUIObject("BossHpBar", topBar.transform);
        SetRect(bossHpBarGo, new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(-40, 25), new Vector2(650, 36));
        Slider bossSlider = bossHpBarGo.AddComponent<Slider>();

        GameObject hpBg = CreateUIObject("Background", bossHpBarGo.transform);
        SetRect(hpBg, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        hpBg.AddComponent<Image>().color = new Color(0.2f, 0.05f, 0.05f, 0.9f);

        GameObject hpFillArea = CreateUIObject("Fill Area", bossHpBarGo.transform);
        SetRect(hpFillArea, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);

        GameObject hpFill = CreateUIObject("Fill", hpFillArea.transform);
        SetRect(hpFill, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Image hpFillImg = hpFill.AddComponent<Image>();
        hpFillImg.color = new Color(0.95f, 0.2f, 0.2f, 1f); // Vibrant glossy red
        bossSlider.fillRect = hpFill.GetComponent<RectTransform>();
        bossSlider.value = 0.645f;
        uiManager.bossHpSlider = bossSlider;

        // Text inside HP Bar: 6,450 / 10,000 HP
        GameObject hpTextGo = CreateUIObject("HpText", bossHpBarGo.transform);
        SetRect(hpTextGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text hpTxt = hpTextGo.AddComponent<Text>();
        hpTxt.font = defaultFont;
        hpTxt.text = "6,450 / 10,000 HP";
        hpTxt.fontSize = 20;
        hpTxt.fontStyle = FontStyle.Bold;
        hpTxt.alignment = TextAnchor.MiddleCenter;
        hpTxt.color = Color.white;
        uiManager.bossHpText = hpTxt;

        // Percent text on right of HP Bar: 64%
        GameObject percentTextGo = CreateUIObject("PercentText", topBar.transform);
        SetRect(percentTextGo, new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(0, 0), new Vector2(305, 27), new Vector2(80, 32));
        Text pctTxt = percentTextGo.AddComponent<Text>();
        pctTxt.font = defaultFont;
        pctTxt.text = "64%";
        pctTxt.fontSize = 20;
        pctTxt.fontStyle = FontStyle.Bold;
        pctTxt.alignment = TextAnchor.MiddleLeft;
        pctTxt.color = Color.white;
        uiManager.bossHpPercentText = pctTxt;

        // Timer container on top right
        GameObject timerGo = CreateUIObject("TimerPanel", topBar.transform);
        SetRect(timerGo, new Vector2(1, 0.5f), new Vector2(1, 0.5f), new Vector2(1, 0.5f), new Vector2(-40, 0), new Vector2(130, 60));
        Text timerTxt = timerGo.AddComponent<Text>();
        timerTxt.font = defaultFont;
        timerTxt.text = "🕒 TIME\n02:45";
        timerTxt.fontSize = 18;
        timerTxt.alignment = TextAnchor.MiddleRight;
        timerTxt.color = new Color(0.8f, 0.9f, 1f, 1f);
        uiManager.timerText = timerTxt;

        // ------------------ BOTTOM SKILL CARDS ROW ------------------
        GameObject cardsPanel = CreateUIObject("SkillCardsPanel", canvasGo.transform);
        SetRect(cardsPanel, new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(0, 160), new Vector2(950, 190));
        HorizontalLayoutGroup hlg = cardsPanel.AddComponent<HorizontalLayoutGroup>();
        hlg.spacing = 15;
        hlg.childAlignment = TextAnchor.MiddleCenter;
        hlg.childControlWidth = false;
        hlg.childControlHeight = false;

        // 5 Cards: Punch, Uppercut, Squat, Plank, High Knee
        uiManager.punchButton = CreateSkillCard(cardsPanel.transform, "PunchCard", "👊 Punch", "โจมตีพื้นฐาน", new Color(0.1f, 0.4f, 0.8f), out uiManager.punchGlow, defaultFont);
        uiManager.uppercutButton = CreateSkillCard(cardsPanel.transform, "UppercutCard", "🥊 Uppercut", "คริติคอลฮิต", new Color(0.85f, 0.55f, 0.1f), out uiManager.uppercutGlow, defaultFont);
        uiManager.squatButton = CreateSkillCard(cardsPanel.transform, "SquatCard", "🦵 Squat", "หลบการโจมตี", new Color(0.2f, 0.75f, 0.3f), out uiManager.squatGlow, defaultFont);
        uiManager.plankButton = CreateSkillCard(cardsPanel.transform, "PlankCard", "🛡️ Plank", "ตั้งโล่ป้องกัน", new Color(0.15f, 0.5f, 0.9f), out uiManager.plankGlow, defaultFont);
        uiManager.highKneeButton = CreateSkillCard(cardsPanel.transform, "HighKneeCard", "🏃 High Knee", "ชาร์จพลังอัลติเมท", new Color(0.9f, 0.7f, 0.15f), out uiManager.highKneeGlow, defaultFont);

        // ------------------ BOTTOM PLAYER BAR ------------------
        GameObject bottomBar = CreateUIObject("BottomPlayerPanel", canvasGo.transform);
        SetRect(bottomBar, new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(0.5f, 0), new Vector2(0, 15), new Vector2(980, 125));

        // Left Player Info Card
        GameObject playerInfoCard = CreateUIObject("PlayerInfoCard", bottomBar.transform);
        SetRect(playerInfoCard, new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0), new Vector2(320, 115));
        Image pBg = playerInfoCard.AddComponent<Image>();
        pBg.color = new Color(0.06f, 0.12f, 0.22f, 0.92f);

        // Player Avatar
        GameObject avatarGo = CreateUIObject("Avatar", playerInfoCard.transform);
        SetRect(avatarGo, new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(15, 0), new Vector2(75, 75));
        Image avatarImg = avatarGo.AddComponent<Image>();
        avatarImg.color = new Color(0.9f, 0.75f, 0.5f); // Placeholder portrait frame

        // "You" text
        GameObject pNameGo = CreateUIObject("PlayerName", playerInfoCard.transform);
        SetRect(pNameGo, new Vector2(0, 1), new Vector2(0, 1), new Vector2(0, 1), new Vector2(105, -15), new Vector2(150, 25));
        Text pNameTxt = pNameGo.AddComponent<Text>();
        pNameTxt.font = defaultFont;
        pNameTxt.text = "You";
        pNameTxt.fontSize = 20;
        pNameTxt.fontStyle = FontStyle.Bold;
        pNameTxt.color = Color.white;
        uiManager.playerNameText = pNameTxt;

        // Player HP Bar: HP 430 / 500
        GameObject pHpBarGo = CreateUIObject("PlayerHpBar", playerInfoCard.transform);
        SetRect(pHpBarGo, new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(105, 5), new Vector2(195, 26));
        Slider pSlider = pHpBarGo.AddComponent<Slider>();
        GameObject pHpBg = CreateUIObject("Bg", pHpBarGo.transform);
        SetRect(pHpBg, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        pHpBg.AddComponent<Image>().color = new Color(0.2f, 0.05f, 0.05f);

        GameObject pHpFill = CreateUIObject("Fill", pHpBarGo.transform);
        SetRect(pHpFill, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Image pHpFillImg = pHpFill.AddComponent<Image>();
        pHpFillImg.color = new Color(0.95f, 0.25f, 0.25f);
        pSlider.fillRect = pHpFill.GetComponent<RectTransform>();
        pSlider.value = 0.86f;
        uiManager.playerHpSlider = pSlider;

        GameObject pHpTxtGo = CreateUIObject("HpTxt", pHpBarGo.transform);
        SetRect(pHpTxtGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text pHpTxt = pHpTxtGo.AddComponent<Text>();
        pHpTxt.font = defaultFont;
        pHpTxt.text = "HP 430 / 500";
        pHpTxt.fontSize = 15;
        pHpTxt.fontStyle = FontStyle.Bold;
        pHpTxt.alignment = TextAnchor.MiddleCenter;
        pHpTxt.color = Color.white;
        uiManager.playerHpText = pHpTxt;

        // ENERGY text & pips
        GameObject pEnergyGo = CreateUIObject("EnergyRow", playerInfoCard.transform);
        SetRect(pEnergyGo, new Vector2(0, 0), new Vector2(0, 0), new Vector2(0, 0), new Vector2(105, 12), new Vector2(200, 20));
        Text energyTxt = pEnergyGo.AddComponent<Text>();
        energyTxt.font = defaultFont;
        energyTxt.text = "ENERGY 🟦🟦🟦🟦⬜ 72%";
        energyTxt.fontSize = 14;
        energyTxt.color = new Color(0.4f, 0.8f, 1f);
        uiManager.energyPercentText = energyTxt;

        // Center Ultimate Meter
        GameObject ultMeterGo = CreateUIObject("UltimateMeter", bottomBar.transform);
        SetRect(ultMeterGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0, 0), new Vector2(140, 140));
        Image ultBg = ultMeterGo.AddComponent<Image>();
        ultBg.color = new Color(0.04f, 0.1f, 0.2f, 0.95f);

        Button ultBtn = ultMeterGo.AddComponent<Button>();
        uiManager.ultimateButton = ultBtn;

        GameObject ultTextGo = CreateUIObject("UltText", ultMeterGo.transform);
        SetRect(ultTextGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text ultTxt = ultTextGo.AddComponent<Text>();
        ultTxt.font = defaultFont;
        ultTxt.text = "⚡ ULTIMATE\n72%";
        ultTxt.fontSize = 18;
        ultTxt.fontStyle = FontStyle.Bold;
        ultTxt.alignment = TextAnchor.MiddleCenter;
        ultTxt.color = new Color(0.4f, 0.9f, 1f);
        uiManager.ultimatePercentText = ultTxt;

        // Right EXP Card
        GameObject expCardGo = CreateUIObject("ExpCard", bottomBar.transform);
        SetRect(expCardGo, new Vector2(1, 0.5f), new Vector2(1, 0.5f), new Vector2(1, 0.5f), new Vector2(0, 0), new Vector2(320, 115));
        Image expBg = expCardGo.AddComponent<Image>();
        expBg.color = new Color(0.06f, 0.12f, 0.22f, 0.92f);

        // EXP +30 label
        GameObject expGainGo = CreateUIObject("ExpGainText", expCardGo.transform);
        SetRect(expGainGo, new Vector2(1, 1), new Vector2(1, 1), new Vector2(1, 1), new Vector2(-20, -15), new Vector2(120, 25));
        Text expGainTxt = expGainGo.AddComponent<Text>();
        expGainTxt.font = defaultFont;
        expGainTxt.text = "+30";
        expGainTxt.fontSize = 22;
        expGainTxt.fontStyle = FontStyle.Bold;
        expGainTxt.alignment = TextAnchor.MiddleRight;
        expGainTxt.color = new Color(0.3f, 1f, 0.4f);
        uiManager.expGainedText = expGainTxt;

        // Level shield badge: 12
        GameObject levelBadgeGo = CreateUIObject("LevelBadge", expCardGo.transform);
        SetRect(levelBadgeGo, new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0.5f), new Vector2(25, -5), new Vector2(50, 50));
        Image badgeImg = levelBadgeGo.AddComponent<Image>();
        badgeImg.color = new Color(0.85f, 0.65f, 0.15f);

        GameObject levelTxtGo = CreateUIObject("LvlText", levelBadgeGo.transform);
        SetRect(levelTxtGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text lvlTxt = levelTxtGo.AddComponent<Text>();
        lvlTxt.font = defaultFont;
        lvlTxt.text = "12";
        lvlTxt.fontSize = 24;
        lvlTxt.fontStyle = FontStyle.Bold;
        lvlTxt.alignment = TextAnchor.MiddleCenter;
        lvlTxt.color = Color.white;
        uiManager.playerLevelText = lvlTxt;

        // EXP Slider: 650 / 900
        GameObject expSliderGo = CreateUIObject("ExpSlider", expCardGo.transform);
        SetRect(expSliderGo, new Vector2(1, 0.5f), new Vector2(1, 0.5f), new Vector2(1, 0.5f), new Vector2(-20, -5), new Vector2(210, 26));
        Slider expSlider = expSliderGo.AddComponent<Slider>();

        GameObject eBg = CreateUIObject("Bg", expSliderGo.transform);
        SetRect(eBg, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        eBg.AddComponent<Image>().color = new Color(0.15f, 0.1f, 0.05f);

        GameObject eFill = CreateUIObject("Fill", expSliderGo.transform);
        SetRect(eFill, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Image eFillImg = eFill.AddComponent<Image>();
        eFillImg.color = new Color(0.95f, 0.7f, 0.15f);
        expSlider.fillRect = eFill.GetComponent<RectTransform>();
        expSlider.value = 0.72f;
        uiManager.playerExpSlider = expSlider;

        GameObject expTxtGo = CreateUIObject("ExpTxt", expSliderGo.transform);
        SetRect(expTxtGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text expTxt = expTxtGo.AddComponent<Text>();
        expTxt.font = defaultFont;
        expTxt.text = "650 / 900";
        expTxt.fontSize = 15;
        expTxt.fontStyle = FontStyle.Bold;
        expTxt.alignment = TextAnchor.MiddleCenter;
        expTxt.color = Color.white;
        uiManager.playerExpText = expTxt;

        // ------------------ OVERLAYS & POPUPS ------------------
        // Combat Feedback Popup
        GameObject feedbackGo = CreateUIObject("CombatFeedbackText", canvasGo.transform);
        SetRect(feedbackGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0, 100), new Vector2(600, 60));
        Text fbTxt = feedbackGo.AddComponent<Text>();
        fbTxt.font = defaultFont;
        fbTxt.fontSize = 32;
        fbTxt.fontStyle = FontStyle.Bold;
        fbTxt.alignment = TextAnchor.MiddleCenter;
        fbTxt.color = Color.yellow;
        feedbackGo.SetActive(false);
        uiManager.combatFeedbackText = fbTxt;

        // Warning Banner
        GameObject warningGo = CreateUIObject("WarningBanner", canvasGo.transform);
        SetRect(warningGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0, 220), new Vector2(700, 70));
        Image wBg = warningGo.AddComponent<Image>();
        wBg.color = new Color(0.8f, 0.1f, 0.1f, 0.85f);
        GameObject wTxtGo = CreateUIObject("Text", warningGo.transform);
        SetRect(wTxtGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text wTxt = wTxtGo.AddComponent<Text>();
        wTxt.font = defaultFont;
        wTxt.text = "⚠️ BOSS ATTACK INCOMING! SQUAT OR PLANK! ⚠️";
        wTxt.fontSize = 24;
        wTxt.fontStyle = FontStyle.Bold;
        wTxt.alignment = TextAnchor.MiddleCenter;
        wTxt.color = Color.white;
        warningGo.SetActive(false);
        uiManager.warningBannerObject = warningGo;
        uiManager.warningBannerText = wTxt;

        // Announcement Banner
        GameObject annGo = CreateUIObject("AnnouncementBanner", canvasGo.transform);
        SetRect(annGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0, 160), new Vector2(650, 60));
        Image aBg = annGo.AddComponent<Image>();
        aBg.color = new Color(0.1f, 0.5f, 0.8f, 0.9f);
        GameObject aTxtGo = CreateUIObject("Text", annGo.transform);
        SetRect(aTxtGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Text aTxt = aTxtGo.AddComponent<Text>();
        aTxt.font = defaultFont;
        aTxt.fontSize = 22;
        aTxt.fontStyle = FontStyle.Bold;
        aTxt.alignment = TextAnchor.MiddleCenter;
        aTxt.color = Color.white;
        annGo.SetActive(false);
        uiManager.announcementObject = annGo;
        uiManager.announcementText = aTxt;

        // Victory Panel
        GameObject vicGo = CreateUIObject("VictoryPanel", canvasGo.transform);
        SetRect(vicGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Image vBg = vicGo.AddComponent<Image>();
        vBg.color = new Color(0, 0, 0, 0.75f);
        GameObject vTxtGo = CreateUIObject("Text", vicGo.transform);
        SetRect(vTxtGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, new Vector2(600, 150));
        Text vTxt = vTxtGo.AddComponent<Text>();
        vTxt.font = defaultFont;
        vTxt.text = "🏆 VICTORY! 🏆\nDragon of Laziness Defeated!\n+500 EXP";
        vTxt.fontSize = 36;
        vTxt.fontStyle = FontStyle.Bold;
        vTxt.alignment = TextAnchor.MiddleCenter;
        vTxt.color = new Color(1f, 0.85f, 0.2f);
        vicGo.SetActive(false);
        uiManager.victoryPanel = vicGo;

        // Defeat Panel
        GameObject defGo = CreateUIObject("DefeatPanel", canvasGo.transform);
        SetRect(defGo, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Image dBg = defGo.AddComponent<Image>();
        dBg.color = new Color(0, 0, 0, 0.75f);
        GameObject dTxtGo = CreateUIObject("Text", defGo.transform);
        SetRect(dTxtGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), Vector2.zero, new Vector2(600, 150));
        Text dTxt = dTxtGo.AddComponent<Text>();
        dTxt.font = defaultFont;
        dTxt.text = "💀 DEFEATED! 💀\nDon't Give Up! Keep Moving!";
        dTxt.fontSize = 36;
        dTxt.fontStyle = FontStyle.Bold;
        dTxt.alignment = TextAnchor.MiddleCenter;
        dTxt.color = new Color(0.9f, 0.2f, 0.2f);
        defGo.SetActive(false);
        uiManager.defeatPanel = defGo;

        Debug.Log("[BattleSetup] Battle Canvas and complete UI hierarchy created.");
        return uiManager;
    }

    private static Button CreateSkillCard(Transform parent, string name, string skillName, string thaiSub, Color themeColor, out Image glowImg, Font font)
    {
        GameObject card = CreateUIObject(name, parent);
        LayoutElement le = card.AddComponent<LayoutElement>();
        le.preferredWidth = 165;
        le.preferredHeight = 185;

        // Card Background
        Image cardBg = card.AddComponent<Image>();
        cardBg.color = new Color(themeColor.r * 0.25f, themeColor.g * 0.25f, themeColor.b * 0.25f, 0.9f);

        // Colored Border
        GameObject border = CreateUIObject("Border", card.transform);
        SetRect(border, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        Image bImg = border.AddComponent<Image>();
        bImg.color = themeColor;

        // Inner Card content
        GameObject inner = CreateUIObject("Inner", border.transform);
        SetRect(inner, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, new Vector2(-4, -4));
        inner.AddComponent<Image>().color = new Color(0.05f, 0.08f, 0.14f, 0.95f);

        // Glow overlay for active/tap feedback
        GameObject glow = CreateUIObject("GlowOverlay", inner.transform);
        SetRect(glow, Vector2.zero, Vector2.one, new Vector2(0.5f, 0.5f), Vector2.zero, Vector2.zero);
        glowImg = glow.AddComponent<Image>();
        glowImg.color = new Color(themeColor.r, themeColor.g, themeColor.b, 0.5f);
        glow.SetActive(false);

        // Skill Title
        GameObject titleGo = CreateUIObject("Title", inner.transform);
        SetRect(titleGo, new Vector2(0, 1), new Vector2(1, 1), new Vector2(0.5f, 1), new Vector2(0, -12), new Vector2(-10, 30));
        Text t = titleGo.AddComponent<Text>();
        t.font = font;
        t.text = skillName;
        t.fontSize = 17;
        t.fontStyle = FontStyle.Bold;
        t.alignment = TextAnchor.MiddleCenter;
        t.color = Color.white;

        // Pose Silhouette Icon area
        GameObject iconGo = CreateUIObject("PoseSilhouette", inner.transform);
        SetRect(iconGo, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0, -5), new Vector2(85, 85));
        Image iImg = iconGo.AddComponent<Image>();
        iImg.color = new Color(themeColor.r, themeColor.g, themeColor.b, 0.7f);

        // Thai Subtitle
        GameObject subGo = CreateUIObject("ThaiSub", inner.transform);
        SetRect(subGo, new Vector2(0, 0), new Vector2(1, 0), new Vector2(0.5f, 0), new Vector2(0, 10), new Vector2(-10, 26));
        Text sub = subGo.AddComponent<Text>();
        sub.font = font;
        sub.text = thaiSub;
        sub.fontSize = 14;
        sub.alignment = TextAnchor.MiddleCenter;
        sub.color = new Color(0.8f, 0.85f, 0.95f);

        Button btn = card.AddComponent<Button>();
        ColorBlock cb = btn.colors;
        cb.highlightedColor = new Color(1.2f, 1.2f, 1.2f);
        cb.pressedColor = new Color(0.7f, 0.7f, 0.7f);
        btn.colors = cb;

        return btn;
    }

    private static GameObject CreateUIObject(string name, Transform parent)
    {
        GameObject go = new GameObject(name);
        go.transform.SetParent(parent, false);
        return go;
    }

    private static void SetRect(GameObject go, Vector2 anchorMin, Vector2 anchorMax, Vector2 pivot, Vector2 anchoredPos, Vector2 sizeDelta)
    {
        RectTransform rt = go.GetComponent<RectTransform>();
        if (rt == null) rt = go.AddComponent<RectTransform>();
        rt.anchorMin = anchorMin;
        rt.anchorMax = anchorMax;
        rt.pivot = pivot;
        rt.anchoredPosition = anchoredPos;
        rt.sizeDelta = sizeDelta;
    }

    [MenuItem("Tools/Setup Real-Time Player Face-Off (No BG Webcam)", false, 12)]
    public static GameObject SetupPlayerPresence()
    {
        Debug.Log("<color=#00E5FF><b>[PlayerPresenceSetup]</b> Setting up Real-Time Player Face-Off Staging...</color>");

        GameObject presenceGo = GameObject.Find("PlayerPresence");
        if (presenceGo == null)
        {
            presenceGo = new GameObject("PlayerPresence");
        }

        // Child 1: Quad for player video cutout
        Transform quadTrans = presenceGo.transform.Find("PlayerCutoutQuad");
        GameObject quadGo;
        if (quadTrans == null)
        {
            quadGo = GameObject.CreatePrimitive(PrimitiveType.Quad);
            quadGo.name = "PlayerCutoutQuad";
            quadGo.transform.SetParent(presenceGo.transform, false);
            var col = quadGo.GetComponent<Collider>();
            if (col != null) Object.DestroyImmediate(col);
        }
        else
        {
            quadGo = quadTrans.gameObject;
        }

        // Material for Cutout
        string matPath = "Assets/Shaders/PlayerLiveCutoutMaterial.mat";
        Material cutoutMat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
        if (cutoutMat == null)
        {
            Shader shader = Shader.Find("Custom/PlayerLiveCutout");
            if (shader == null) shader = Shader.Find("Universal Render Pipeline/Unlit");
            cutoutMat = new Material(shader);
            AssetDatabase.CreateAsset(cutoutMat, matPath);
            AssetDatabase.SaveAssets();
        }

        MeshRenderer mr = quadGo.GetComponent<MeshRenderer>();
        if (mr != null) mr.sharedMaterial = cutoutMat;

        // Child 2: Soft ground shadow
        Transform shadowTrans = presenceGo.transform.Find("GroundShadow");
        GameObject shadowGo;
        if (shadowTrans == null)
        {
            shadowGo = GameObject.CreatePrimitive(PrimitiveType.Quad);
            shadowGo.name = "GroundShadow";
            shadowGo.transform.SetParent(presenceGo.transform, false);
            shadowGo.transform.localPosition = new Vector3(0f, -0.95f, 0f);
            shadowGo.transform.localEulerAngles = new Vector3(90f, 0f, 0f);
            shadowGo.transform.localScale = new Vector3(1.2f, 0.8f, 1f);
            var col = shadowGo.GetComponent<Collider>();
            if (col != null) Object.DestroyImmediate(col);
        }
        else
        {
            shadowGo = shadowTrans.gameObject;
        }

        // Child 3: Energy Shield
        Transform shieldTrans = presenceGo.transform.Find("EnergyShield");
        GameObject shieldGo;
        if (shieldTrans == null)
        {
            shieldGo = GameObject.CreatePrimitive(PrimitiveType.Quad);
            shieldGo.name = "EnergyShield";
            shieldGo.transform.SetParent(presenceGo.transform, false);
            shieldGo.transform.localPosition = new Vector3(0f, 0f, 0.25f);
            shieldGo.transform.localEulerAngles = Vector3.zero;
            shieldGo.transform.localScale = new Vector3(1.6f, 1.8f, 1f);
            var col = shieldGo.GetComponent<Collider>();
            if (col != null) Object.DestroyImmediate(col);
            shieldGo.SetActive(false);
        }
        else
        {
            shieldGo = shieldTrans.gameObject;
        }

        // Attach & configure PlayerPresenceManager
        PlayerPresenceManager ppm = presenceGo.GetComponent<PlayerPresenceManager>();
        if (ppm == null) ppm = presenceGo.AddComponent<PlayerPresenceManager>();

        ppm.playerQuadRenderer = mr;
        ppm.cutoutMaterial = cutoutMat;
        ppm.groundShadow = shadowGo;
        ppm.energyShield = shieldGo;

        // Perform staging alignment
        ppm.AlignFaceOffStaging();

        UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(
            UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene()
        );

        Debug.Log("<color=#4CAF50><b>[PlayerPresenceSetup]</b> Real-Time Player Face-Off setup complete!</color>");
        return presenceGo;
    }
}
#endif
