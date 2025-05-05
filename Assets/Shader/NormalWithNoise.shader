Shader "Unlit/NormalWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump"{}
        _NoiseMap ("Noise Map", 2D) = "white" {}
        _Strength ("Normal Strength", Range(0,4)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; //xyz = tangent direction, w = tangent sign
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 wPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;
            float _Strength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.bitangent = cross (o.normal, o.tangent) * (v.tangent.w * unity_WorldTransformParams.w);

                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float noise  = tex2D(_NoiseMap, i.uv).r;
                float weight = noise * _Strength;

                float3 finalTS = normalize( lerp(float3(0,0,1), tangentSpaceNormal, weight) );

                float3x3 mtxTangToWorld = {
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                };

                float3 N = mul(mtxTangToWorld,finalTS);
                

            }
            ENDCG
        }
    }
}
