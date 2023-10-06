// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/HealthBarCliped"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Texture", Range(0,1)) = 1
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
            
            sampler2D _MainTex;
            float _Health;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolator
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 pos: TEXCOORD1;
            };


            Interpolator vert (MeshData v)
            {
                Interpolator o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; //TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float InverseLerp(float a, float b, float v){
                return (v-a)/(b-a);
            }

            fixed4 frag (Interpolator i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                float healthMask = _Health > i.uv;
                float3 red = float3(1,0,0);
                float3 green = float3(0,1,0);
                float3 black = float3(0,0,0);

                float healthClamped = InverseLerp(0.2,0.8,_Health);

                float3 healthColor = lerp(red,green,healthClamped);
                float3 healthBar = lerp(black,healthColor,healthMask);

                float2 uvCenter = (0.5,0.5);
                float uvDistance = distance(uvCenter, i.uv);
                float roundMask = uvDistance > 0.5;

                return float4(length(i.pos.x),0,0,1);
            }
            ENDCG
        }
    }
}
