Shader "Unlit/Top1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampTex("RampTexture", 2D) = "white" {}
        _MinY("MinY", float) = 0.0
        _MaxY("MaxY", float) = 1.0
        _Color("Color", Color) = (1,1,1,1)
        _RampColor("RampColor", Color) = (1,1,1,1)
        _MapThreshold("MapThresh", float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
               "TerrainCompatible" = "True"
    }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
             #define LUM(c) ((c).r*.3 + (c).g*.59 + (c).b*.11)

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                //world pos
                float3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _RampTex;
            float4 _MainTex_ST;
            float _MinY;
            float _MaxY;
            float4 _Color;
            float4 _RampColor;
            float4 _RampTex_TexelSize;
            float _MapThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                //world pos
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
               

                fixed u = (i.wPos.y - _MinY) / (_MaxY - _MinY);
                u = saturate(u);
                fixed4 col = tex2D(_RampTex, fixed2(u, 0.5));
                col;
                float3 C = tex2D(_RampTex, col).rgb;
                float3 N = tex2D(_RampTex, col + fixed2(0, _RampTex_TexelSize.y)).rgb;
                float3 S = tex2D(_RampTex, col - fixed2(0, _RampTex_TexelSize.y)).rgb;
                float3 W = tex2D(_RampTex, col + fixed2(_RampTex_TexelSize.x, 0)).rgb;
                float3 E = tex2D(_RampTex, col - fixed2(_RampTex_TexelSize.x, 0)).rgb;

                // Luminosity
                float C_lum = LUM(C);
                float N_lum = LUM(N);
                float S_lum = LUM(S);
                float W_lum = LUM(W);
                float E_lum = LUM(E);

                // Laplacian
                float L_lum = saturate(N_lum + S_lum + W_lum + E_lum - 4 * C_lum);

                L_lum = step(_MapThreshold, L_lum);
                return (col * _RampColor) + (float4(L_lum, L_lum, L_lum, 1) * _Color);
                //return col;
            }
            ENDCG
        }
    }
}
