// Unity C# Script: VFXManager.cs
// Location: unity_project/Assets/Scripts/VFXManager.cs

using UnityEngine;
using System.Collections.Generic;

public class VFXManager : MonoBehaviour
{
    public static VFXManager Instance { get; private set; }

    [Header("VFX Prefabs")]
    public GameObject hitEffectPrefab;
    public GameObject criticalHitEffectPrefab;
    public GameObject shieldEffectPrefab;
    public GameObject dodgeEffectPrefab;
    public GameObject healEffectPrefab;
    public GameObject deathEffectPrefab;

    [Header("Object Pooling")]
    public int poolSize = 10;
    private Dictionary<string, Queue<GameObject>> vfxPools = new Dictionary<string, Queue<GameObject>>();

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        // Initialize pools
        InitializePool("hit", hitEffectPrefab);
        InitializePool("critical", criticalHitEffectPrefab);
        InitializePool("shield", shieldEffectPrefab);
        InitializePool("dodge", dodgeEffectPrefab);
        InitializePool("heal", healEffectPrefab);
        InitializePool("death", deathEffectPrefab);
    }

    void InitializePool(string poolName, GameObject prefab)
    {
        if (prefab == null) return;

        Queue<GameObject> pool = new Queue<GameObject>();

        for (int i = 0; i < poolSize; i++)
        {
            GameObject obj = Instantiate(prefab);
            obj.SetActive(false);
            obj.transform.SetParent(transform);
            pool.Enqueue(obj);
        }

        vfxPools[poolName] = pool;
    }

    GameObject GetFromPool(string poolName)
    {
        if (!vfxPools.ContainsKey(poolName)) return null;

        Queue<GameObject> pool = vfxPools[poolName];

        if (pool.Count > 0)
        {
            GameObject obj = pool.Dequeue();
            obj.SetActive(true);
            return obj;
        }

        // Pool empty, create new
        GameObject prefab = GetPrefabByName(poolName);
        if (prefab != null)
        {
            return Instantiate(prefab);
        }

        return null;
    }

    void ReturnToPool(string poolName, GameObject obj)
    {
        if (!vfxPools.ContainsKey(poolName)) return;

        obj.SetActive(false);
        obj.transform.SetParent(transform);
        vfxPools[poolName].Enqueue(obj);
    }

    GameObject GetPrefabByName(string name)
    {
        switch (name)
        {
            case "hit": return hitEffectPrefab;
            case "critical": return criticalHitEffectPrefab;
            case "shield": return shieldEffectPrefab;
            case "dodge": return dodgeEffectPrefab;
            case "heal": return healEffectPrefab;
            case "death": return deathEffectPrefab;
            default: return null;
        }
    }

    // Public methods to spawn VFX
    public void SpawnHitEffect(Vector3 position, Quaternion rotation)
    {
        SpawnEffect("hit", position, rotation, 1f);
    }

    public void SpawnCriticalHitEffect(Vector3 position, Quaternion rotation)
    {
        SpawnEffect("critical", position, rotation, 1.5f);
    }

    public void SpawnShieldEffect(Vector3 position)
    {
        SpawnEffect("shield", position, Quaternion.identity, 3f);
    }

    public void SpawnDodgeEffect(Vector3 position, Quaternion rotation)
    {
        SpawnEffect("dodge", position, rotation, 0.5f);
    }

    public void SpawnHealEffect(Vector3 position)
    {
        SpawnEffect("heal", position, Quaternion.identity, 2f);
    }

    public void SpawnDeathEffect(Vector3 position)
    {
        SpawnEffect("death", position, Quaternion.identity, 3f);
    }

    void SpawnEffect(string effectName, Vector3 position, Quaternion rotation, float lifetime)
    {
        GameObject effect = GetFromPool(effectName);

        if (effect != null)
        {
            effect.transform.position = position;
            effect.transform.rotation = rotation;

            ParticleSystem ps = effect.GetComponent<ParticleSystem>();
            if (ps != null)
            {
                ps.Play();
            }

            // Return to pool after lifetime
            StartCoroutine(ReturnAfterDelay(effectName, effect, lifetime));
        }
    }

    System.Collections.IEnumerator ReturnAfterDelay(string poolName, GameObject obj, float delay)
    {
        yield return new WaitForSeconds(delay);
        ReturnToPool(poolName, obj);
    }
}
