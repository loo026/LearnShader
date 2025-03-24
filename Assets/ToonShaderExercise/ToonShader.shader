Shader "Unlit/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Direction ("Direction", Vector) = (0,0,0,0)
        _Cutoff ("Cutoff Threshold", Float) = 0.2
        _LightStrength ("Light Strength", Float) = 1.0
        _HeightMin ("Min Height", Float) = 0.0
        _HeightMax ("Max Height", Float) = 2.0
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
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
               // float2 uv : TEXCOORD0; // object's uv
            };

            struct v2f
            {
                //float2 uv : TEXCOORD0; // pass object's uv
                float4 vertex : SV_POSITION;
                nointerpolation float toonShade : TEXCOORD1;
                float worldY : TEXCOORD2; //world-space Y coordinate, stored in TEXCOORD2
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Direction;
            float _Cutoff;
            float _LightStrength;
            float _HeightMin;
            float _HeightMax;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                float3 normalWorld = normalize(UnityObjectToWorldNormal(v.normal));
                float3 lightDir = normalize(_Direction);
                float NdotL = dot(normalWorld,lightDir);
                float mask = step(_Cutoff, NdotL); // if >=Threshold return 1
                o.toonShade = lerp(0.1,_LightStrength, mask);
                
                //convert object-space vertex position to world-space
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldY = worldPos.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float height = saturate((i.worldY - _HeightMin)/(_HeightMax- _HeightMin));//normalize world Y[0,1]
                float2 uv = float2(0.5, height); // use height as vertical UV to sample gradient texture
                fixed4 texColor = tex2D(_MainTex, uv);

                fixed4 finalColor = texColor * i.toonShade;
                return finalColor;
            }
            ENDCG
        }
    }
}
