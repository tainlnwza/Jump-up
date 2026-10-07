Shader "Custom/PlayerLiveCutout"
{
    Properties
    {
        _MainTex ("Player Camera Feed", 2D) = "white" {}
        _MaskTex ("MediaPipe Segmentation Mask", 2D) = "white" {}
        _UseMask ("Use Segmentation Mask (1=Yes, 0=No)", Float) = 0.0
        _ChromaColor ("Chroma Key Color", Color) = (0.0, 1.0, 0.0, 1.0)
        _Threshold ("Chroma Threshold", Range(0.0, 1.0)) = 0.35
        _Smoothing ("Chroma Smoothing", Range(0.001, 0.5)) = 0.1
        _AuraColor ("Combat Aura Color", Color) = (0.2, 0.7, 1.0, 1.0)
        _AuraIntensity ("Aura Intensity", Range(0.0, 3.0)) = 1.0
        _MirrorX ("Mirror Horizontally (1=Yes, 0=No)", Float) = 1.0
        _Brightness ("Brightness", Range(0.5, 2.0)) = 1.1
        _Contrast ("Contrast", Range(0.5, 2.0)) = 1.15
        _HitFlash ("Hit Flash Intensity", Range(0.0, 1.0)) = 0.0
        _HologramEffect ("Hologram Effect (1=Yes, 0=No)", Float) = 0.0
    }

    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent" 
            "RenderPipeline"="UniversalPipeline" 
        }
        LOD 100
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "PlayerCutoutForward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _ChromaColor;
                float4 _AuraColor;
                float _Threshold;
                float _Smoothing;
                float _AuraIntensity;
                float _UseMask;
                float _MirrorX;
                float _Brightness;
                float _Contrast;
                float _HitFlash;
                float _HologramEffect;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                if (_MirrorX > 0.5)
                {
                    output.uv.x = 1.0 - output.uv.x;
                }
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

                // Contrast & Brightness adjustment
                col.rgb = (col.rgb - 0.5) * _Contrast + 0.5;
                col.rgb *= _Brightness;

                half alpha = 1.0;

                if (_UseMask > 0.5)
                {
                    // MediaPipe Segmentation: 1 = Human, 0 = Background
                    half maskVal = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv).r;
                    alpha = smoothstep(0.2, 0.8, maskVal);
                }
                else
                {
                    // Real-time chroma key cutout
                    float dist = distance(col.rgb, _ChromaColor.rgb);
                    alpha = smoothstep(_Threshold, _Threshold + _Smoothing, dist);
                }

                // Hologram cyber scanline effect
                if (_HologramEffect > 0.5)
                {
                    float scanline = sin(input.uv.y * 120.0 + _Time.y * 8.0) * 0.15 + 0.85;
                    col.rgb = lerp(col.rgb, _AuraColor.rgb * 1.2, 0.35) * scanline;
                }

                // Combat edge aura
                float auraEdge = (1.0 - alpha) * step(0.01, alpha);
                col.rgb = lerp(col.rgb, _AuraColor.rgb * _AuraIntensity * 1.5, auraEdge * 0.75);

                // Hit flash feedback (Damage taken)
                if (_HitFlash > 0.01)
                {
                    col.rgb = lerp(col.rgb, float3(1.0, 0.15, 0.15), _HitFlash);
                }

                return half4(col.rgb, alpha);
            }
            ENDHLSL
        }
    }

    // Fallback for Built-in Pipeline
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float4 vertex : SV_POSITION; float2 uv : TEXCOORD0; };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _ChromaColor;
            float4 _AuraColor;
            float _Threshold;
            float _Smoothing;
            float _AuraIntensity;
            float _UseMask;
            float _MirrorX;
            float _Brightness;
            float _Contrast;
            float _HitFlash;
            float _HologramEffect;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                if (_MirrorX > 0.5) o.uv.x = 1.0 - o.uv.x;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = (col.rgb - 0.5) * _Contrast + 0.5;
                col.rgb *= _Brightness;

                fixed alpha = 1.0;
                if (_UseMask > 0.5)
                {
                    alpha = tex2D(_MaskTex, i.uv).r;
                }
                else
                {
                    float dist = distance(col.rgb, _ChromaColor.rgb);
                    alpha = smoothstep(_Threshold, _Threshold + _Smoothing, dist);
                }

                if (_HologramEffect > 0.5)
                {
                    float scanline = sin(i.uv.y * 120.0 + _Time.y * 8.0) * 0.15 + 0.85;
                    col.rgb = lerp(col.rgb, _AuraColor.rgb * 1.2, 0.35) * scanline;
                }

                float auraEdge = (1.0 - alpha) * step(0.01, alpha);
                col.rgb = lerp(col.rgb, _AuraColor.rgb * _AuraIntensity * 1.5, auraEdge * 0.75);

                if (_HitFlash > 0.01)
                {
                    col.rgb = lerp(col.rgb, float3(1.0, 0.15, 0.15), _HitFlash);
                }

                return fixed4(col.rgb, alpha);
            }
            ENDCG
        }
    }
}
