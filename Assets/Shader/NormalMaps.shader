Shader "Custom/NormalWithNoise" {
    Properties {
        _MainMap ("Main Map", 2D) = "white" { }
        _NormalMap ("Normal Map", 2D) = "bump" { }
        _NoiseMap ("Noise Map", 2D) = "white" { }
        _NormalStrength ("Normal Strength", Float) = 1.0
        _Direction ("Direction", Vector) = (0.0, 1.0, 0.0)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _NormalMap;
            sampler2D _NoiseMap;
            sampler2D _MainMap;
            float _NormalStrength;
            float3 _Direction;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3x3 tbn : TEXCOORD1;
            };

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //the axes of tangent space are converted to world space at this stage but could happen later too
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 bitangent = cross(normal, tangent) * v.tangent.w;

                o.tbn = float3x3(tangent, bitangent, normal);
                o.uv = v.uv;

                return o;
            }

            float4 frag(v2f i) : SV_Target {
                // Sample base color and normal map
                half3 baseColor = tex2D(_MainMap, i.uv).rgb;

                //In a normal map, RGB values are stored in [0, 1],
                //but real normals in tangent space have components like (-0.5, 0.8, 0.2),
                //i.e., they span both positive and negative values.
                half3 tangentNormal = tex2D(_NormalMap, i.uv).rgb * 2.0 - 1.0;

                // Sample noise strength
                float noiseValue = tex2D(_NoiseMap, i.uv).r;

                // Transform to world space using TBN
                
                // Simple directional lighting
                float3 lightDir = normalize(_Direction);

                //the first attempt was to multiply the normal by strength
                //but this results in a weird abstract situation where a normal
                //can become 0 and hence have 'no direction' which makes no sense
                //tangentNormal *= (noiseValue * _NormalStrength);

                //instead lerp between the default normal and the adjusted normal
                //depending on the strength
                
                float3 flatNormal = float3(0.0, 0.0, 1.0);
                tangentNormal = lerp(flatNormal, tangentNormal, noiseValue);
                float3 worldNormal = normalize(mul(i.tbn, tangentNormal));

                float ndotl = saturate(dot(worldNormal, lightDir));
                
                // Modulate base color by lighting
                return float4(baseColor * ndotl, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
