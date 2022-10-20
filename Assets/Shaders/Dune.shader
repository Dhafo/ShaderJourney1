Shader "Custom/Dune"
{
    Properties
    {
        _TerrainColor ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ShadowColor("Color", Color) = (1,1,1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Journey fullforwardshadows
            // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        float4 LightingJourney(SurfaceOutput s, fixed3 viewDir, UnityGI gi)
        {
            float3 L = gi.light.dir;
            float3 N = s.Normal;
            float3 diffuseColor = DiffuseColor(N,L);
            float3 rimColor = RimLighting();
            float3 oceanColor = OceanSpecular();
            float3 glitterColor = GlitterSpecular();
            float3 specularColor = saturate(max(rimColor, oceanColor));
            float3 color = diffuseColor + specularColor + glitterColor;

            return float4(color * s.Albedo, 1);
        }

        float3 DiffuseColor(float3 N, float3 L)
        {
            //Journey sand reflectance model
            N.y *= 0.3;
            float NdotL = saturate(4 * dot(N,L));
            float3 color = lerp(_ShadowColor, _TerrainColor, NdotL);
            return color;
        }

        

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _TerrainColor;
        fixed4 _ShadowColor;

        
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _TerrainColor;
            o.Alpha = 1;

            float3 N = float3(0, 0, 1);
            //N = RipplesNormal(N);
            //N = SandNormal(N);

            o.Normal = N;
            o.Albedo = LightingJourney(o, N, gi);
            return o;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
