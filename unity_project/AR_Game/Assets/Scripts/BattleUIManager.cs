using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class BattleUIManager : MonoBehaviour
{
    [Header("Top Bar (Boss UI)")]
    public Text bossNameText;
    public Slider bossHpSlider;
    public Text bossHpText;
    public Text bossHpPercentText;
    public Text timerText;

    [Header("Bottom Bar (Player UI)")]
    public Text playerNameText;
    public Slider playerHpSlider;
    public Text playerHpText;
    public Image[] energyBlocks;
    public Text energyPercentText;
    public Image ultimateRingFill;
    public Text ultimatePercentText;
    public Text expGainedText;
    public Text playerLevelText;
    public Slider playerExpSlider;
    public Text playerExpText;

    [Header("Skill Card Buttons")]
    public Button punchButton;
    public Button uppercutButton;
    public Button squatButton;
    public Button plankButton;
    public Button highKneeButton;
    public Button ultimateButton;

    [Header("Skill Card Highlight Overlays")]
    public Image punchGlow;
    public Image uppercutGlow;
    public Image squatGlow;
    public Image plankGlow;
    public Image highKneeGlow;

    [Header("Popups & Notifications")]
    public Text combatFeedbackText;
    public GameObject warningBannerObject;
    public Text warningBannerText;
    public GameObject announcementObject;
    public Text announcementText;
    public GameObject victoryPanel;
    public GameObject defeatPanel;

    private Coroutine feedbackRoutine;
    private Coroutine announcementRoutine;

    void Start()
    {
        // Wire up UI Card click events
        if (punchButton != null) punchButton.onClick.AddListener(() => BattleManager.Instance?.ExecuteAction(PlayerActionType.Punch));
        if (uppercutButton != null) uppercutButton.onClick.AddListener(() => BattleManager.Instance?.ExecuteAction(PlayerActionType.Uppercut));
        if (squatButton != null) squatButton.onClick.AddListener(() => BattleManager.Instance?.ExecuteAction(PlayerActionType.Squat));
        if (plankButton != null) plankButton.onClick.AddListener(() => BattleManager.Instance?.ExecuteAction(PlayerActionType.Plank));
        if (highKneeButton != null) highKneeButton.onClick.AddListener(() => BattleManager.Instance?.ExecuteAction(PlayerActionType.HighKnee));
        if (ultimateButton != null) ultimateButton.onClick.AddListener(() => BattleManager.Instance?.ExecuteAction(PlayerActionType.Ultimate));

        if (warningBannerObject != null) warningBannerObject.SetActive(false);
        if (announcementObject != null) announcementObject.SetActive(false);
        if (victoryPanel != null) victoryPanel.SetActive(false);
        if (defeatPanel != null) defeatPanel.SetActive(false);
    }

    public void UpdateBossUI(string name, int currentHp, int maxHp)
    {
        if (bossNameText != null) bossNameText.text = name;

        float ratio = maxHp > 0 ? (float)currentHp / maxHp : 0;
        if (bossHpSlider != null) bossHpSlider.value = ratio;

        if (bossHpText != null) bossHpText.text = $"{currentHp:N0} / {maxHp:N0} HP";
        if (bossHpPercentText != null) bossHpPercentText.text = $"{Mathf.RoundToInt(ratio * 100)}%";
    }

    public void UpdatePlayerUI(string name, int currentHp, int maxHp, int energyCount, float energyPercent, float ultPercent, int level, int exp, int maxExp, int expGained)
    {
        if (playerNameText != null) playerNameText.text = name;

        float hpRatio = maxHp > 0 ? (float)currentHp / maxHp : 0;
        if (playerHpSlider != null) playerHpSlider.value = hpRatio;
        if (playerHpText != null) playerHpText.text = $"HP {currentHp} / {maxHp}";

        // Energy blocks
        if (energyBlocks != null)
        {
            for (int i = 0; i < energyBlocks.Length; i++)
            {
                if (energyBlocks[i] != null)
                {
                    energyBlocks[i].color = i < energyCount ? new Color(0.2f, 0.7f, 1f, 1f) : new Color(0.2f, 0.3f, 0.5f, 0.3f);
                }
            }
        }
        if (energyPercentText != null) energyPercentText.text = $"{Mathf.RoundToInt(energyPercent)}%";

        // Ultimate ring
        float ultRatio = Mathf.Clamp01(ultPercent / 100f);
        if (ultimateRingFill != null) ultimateRingFill.fillAmount = ultRatio;
        if (ultimatePercentText != null) ultimatePercentText.text = $"{Mathf.RoundToInt(ultPercent)}%";

        // EXP & Level
        if (playerLevelText != null) playerLevelText.text = level.ToString();
        if (expGainedText != null) expGainedText.text = $"+{expGained}";
        float expRatio = maxExp > 0 ? (float)exp / maxExp : 0;
        if (playerExpSlider != null) playerExpSlider.value = expRatio;
        if (playerExpText != null) playerExpText.text = $"{exp} / {maxExp}";
    }

    public void UpdateTimer(float timeSeconds)
    {
        if (timerText == null) return;
        int minutes = Mathf.FloorToInt(timeSeconds / 60F);
        int seconds = Mathf.FloorToInt(timeSeconds % 60F);
        timerText.text = $"{minutes:00}:{seconds:00}";
    }

    public void HighlightCard(PlayerActionType action)
    {
        Image targetGlow = null;
        switch (action)
        {
            case PlayerActionType.Punch: targetGlow = punchGlow; break;
            case PlayerActionType.Uppercut: targetGlow = uppercutGlow; break;
            case PlayerActionType.Squat: targetGlow = squatGlow; break;
            case PlayerActionType.Plank: targetGlow = plankGlow; break;
            case PlayerActionType.HighKnee: targetGlow = highKneeGlow; break;
        }

        if (targetGlow != null)
        {
            StartCoroutine(FlashGlowRoutine(targetGlow));
        }
    }

    private IEnumerator FlashGlowRoutine(Image glow)
    {
        glow.gameObject.SetActive(true);
        glow.color = new Color(glow.color.r, glow.color.g, glow.color.b, 1f);
        yield return new WaitForSeconds(0.4f);
        glow.gameObject.SetActive(false);
    }

    public void ShowCombatFeedback(string message, Color color)
    {
        if (combatFeedbackText == null) return;
        if (feedbackRoutine != null) StopCoroutine(feedbackRoutine);
        feedbackRoutine = StartCoroutine(CombatFeedbackRoutine(message, color));
    }

    private IEnumerator CombatFeedbackRoutine(string message, Color color)
    {
        combatFeedbackText.text = message;
        combatFeedbackText.color = color;
        combatFeedbackText.gameObject.SetActive(true);

        yield return new WaitForSeconds(1.5f);
        combatFeedbackText.gameObject.SetActive(false);
    }

    public void ShowBossWarning(string message)
    {
        if (warningBannerObject != null)
        {
            if (warningBannerText != null) warningBannerText.text = message;
            warningBannerObject.SetActive(true);
        }
    }

    public void HideBossWarning()
    {
        if (warningBannerObject != null)
        {
            warningBannerObject.SetActive(false);
        }
    }

    public void ShowAnnouncement(string message, Color color)
    {
        if (announcementObject == null) return;
        if (announcementRoutine != null) StopCoroutine(announcementRoutine);
        announcementRoutine = StartCoroutine(AnnouncementRoutine(message, color));
    }

    private IEnumerator AnnouncementRoutine(string message, Color color)
    {
        if (announcementText != null)
        {
            announcementText.text = message;
            announcementText.color = color;
        }
        announcementObject.SetActive(true);
        yield return new WaitForSeconds(3f);
        announcementObject.SetActive(false);
    }

    public void ShowVictoryScreen()
    {
        if (victoryPanel != null) victoryPanel.SetActive(true);
    }

    public void ShowDefeatScreen()
    {
        if (defeatPanel != null) defeatPanel.SetActive(true);
    }
}
