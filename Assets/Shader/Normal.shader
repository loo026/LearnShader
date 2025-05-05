Shader "Custom/Normal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NormalMap ("Normal Map", 2D)= "bump"{}
        _NoiseMap ("Noise Map", 2D) = "white" {}
        _Strength ("Strength" , Range(0,4)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _NoiseMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_NoiseMap;
        };

        half _Glossiness;
        half _Metallic;
        float _Strength;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            //normal = (2*color)-1 
            //transform normal vector[0,1] to Tangent Space range [-1,1]
            float3 n = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
          
            float noise = tex2D(_NoiseMap, IN.uv_NoiseMap).r;
            float weight = noise * _Strength;
            float3 finalNormal = normalize(lerp(float3(0,0,1), n, weight)); //(0,0,1) = plane

            o.Normal   = finalNormal;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
