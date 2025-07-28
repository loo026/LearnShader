Shader "Custom/BlendedNormalsWithNoise"
{
    Properties
    {
        _MainMap ("Main Map", 2D) = "white" {}
        _NormalMap1 ("Normal Map 1", 2D) = "bump" {}
        _NormalMap2 ("Normal Map 2", 2D) = "bump" {}
        _NoiseMap ("Noise Map", 2D) = "white" {}
        _NormalStrength ("Normal Strength", Float) = 1.0
        _Direction ("Direction", Vector) = (0.0, 1.0, 0.0)

        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Float) = 16

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainMap;
            sampler2D _NormalMap1;
            sampler2D _NormalMap2;
            sampler2D _NoiseMap;
            float _NormalStrength;
            float3 _Direction;
            float4 _SpecColor;
            float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3x3 tbn : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 bitangent = cross(normal, tangent) * v.tangent.w;

                o.tbn = float3x3(tangent, bitangent, normal);
                o.uv = v.uv;

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // Base color
                half3 baseColor = tex2D(_MainMap, i.uv).rgb;

                // Sample both normal maps and convert to tangent-space normals
                float3 normal1 = tex2D(_NormalMap1, i.uv).rgb * 2.0 - 1.0;
                float3 normal2 = tex2D(_NormalMap2, i.uv).rgb * 2.0 - 1.0;

                // Sample noise value for blending
                float weight = tex2D(_NoiseMap, i.uv).r;

                // Blend the two normals
                float3 blendedNormal = normalize(lerp(normal2, normal1, weight));

                // Apply strength by interpolating with flat normal
                float3 flatNormal = float3(0.0, 0.0, 1.0);
                blendedNormal = lerp(flatNormal, blendedNormal, _NormalStrength);

                // Convert to world space
                float3 worldNormal = normalize(mul(i.tbn, blendedNormal));

                // Simple directional lighting
                float3 lightDir = normalize(_Direction);
                float ndotl = saturate(dot(worldNormal, lightDir));

                float3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz);
                float3 reflectDir = reflect(-lightDir, worldNormal);
                float spec = pow(saturate(dot(viewDir, reflectDir)), _Shininess);

                float3 ambient = 0.1 * baseColor;
                float3 diffuse = baseColor * ndotl;
                float3 specular = _SpecColor.rgb * spec;
                float3 finalColor = ambient + diffuse + specular;

                return float4(finalColor, 1.0);
                //return float4(baseColor * ndotl, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
