// Unity C# Script: DamageNumber.cs
// Location: unity_project/Assets/Scripts/DamageNumber.cs

using UnityEngine;
using TMPro;

public class DamageNumber : MonoBehaviour
{
    public TextMeshPro textMesh;
    public float lifetime = 1.5f;
    public float floatSpeed = 1f;
    public float fadeSpeed = 1f;

    private float timer = 0f;
    private Vector3 startPos;
    private Color startColor;

    void Start()
    {
        if (textMesh == null)
        {
            textMesh = GetComponentInChildren<TextMeshPro>();
        }

        startPos = transform.position;

        if (textMesh != null)
        {
            startColor = textMesh.color;
        }

        // Always face camera
        if (Camera.main != null)
        {
            transform.LookAt(Camera.main.transform);
            transform.Rotate(0, 180, 0);
        }
    }

    public void Initialize(int damage, bool isCritical)
    {
        if (textMesh == null)
        {
            textMesh = GetComponentInChildren<TextMeshPro>();
        }

        if (textMesh != null)
        {
            textMesh.text = damage.ToString();

            if (isCritical)
            {
                textMesh.color = new Color(1f, 0.2f, 0.2f); // Red
                textMesh.fontSize = 6f;
                textMesh.fontStyle = FontStyles.Bold;
            }
            else
            {
                textMesh.color = Color.white;
                textMesh.fontSize = 4f;
            }

            startColor = textMesh.color;
        }
    }

    void Update()
    {
        timer += Time.deltaTime;

        // Float upward with slight arc
        float t = timer / lifetime;
        Vector3 offset = Vector3.up * floatSpeed * timer;
        offset.x += Mathf.Sin(t * Mathf.PI) * 0.2f;
        transform.position = startPos + offset;

        // Fade out
        if (textMesh != null)
        {
            Color color = startColor;
            color.a = Mathf.Lerp(1f, 0f, t);
            textMesh.color = color;
        }

        // Scale up then down
        float scale = 1f + Mathf.Sin(t * Mathf.PI) * 0.3f;
        transform.localScale = Vector3.one * scale;

        // Always face camera
        if (Camera.main != null)
        {
            transform.LookAt(Camera.main.transform);
            transform.Rotate(0, 180, 0);
        }

        // Destroy when done
        if (timer >= lifetime)
        {
            Destroy(gameObject);
        }
    }
}
