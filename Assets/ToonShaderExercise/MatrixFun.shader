Shader "Custom/TransformShader"
{
    Properties
    {
        _Direction ("Direction", Vector) = (0,1,0)
        _Color ("Color", Color) = (1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 normal : TEXCOORD0;
            };

            float4x4 _TransformMatrix;
            float3 _Direction;
            float3 _Color;
            
            v2f vert (float4 pos : POSITION, float4 normal : NORMAL)
            {
                v2f o;
                o.normal = normal;
                float4 transformedPos = mul(_TransformMatrix, pos);
                o.pos = UnityObjectToClipPos(transformedPos);
                return o;
            }

            sampler2D _MainTex;
            fixed4 frag (v2f i) : SV_Target
            {
                float ndotv = saturate(dot(_Direction, i.normal));
                float3 color = _Color * ndotv;
                return float4(color,1);
            }
            ENDCG
        }
    }
}