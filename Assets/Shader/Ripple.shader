Shader "Custom/Ripple"
{
    Properties
    {
        _Amplitude ("Ripple Amplitude", Float) = 0.05
        _Frequency ("Ripple Frequency", Float) = 10.0
        _Speed     ("Ripple Speed", Float)     = 1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
             #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float4x4 _TransformMatrix;
            float _Amplitude;
            float _Frequency;
            float _Speed;
            
            v2f vert (float4 pos : POSITION)
            {
                v2f o;
                float yOff = sin(pos.x * _Frequency * 0.5 + _Time.y * _Speed) * (_Amplitude * 0.5);
                pos.y += yOff;

                float4 transformedPos = mul(_TransformMatrix, pos);
                o.pos = UnityObjectToClipPos(transformedPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }

            ENDCG
        }
    }
}