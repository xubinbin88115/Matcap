// MatCap Shader, (c) 2015-2019 Jean Moreno

Shader "MatCap/Vertex/Textured Multiply"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MatCap ("MatCap (RGB)", 2D) = "white" {}
        _NormalScale ("Normal Scale", Range(0.1, 1)) = 1
	}
	
	Subshader
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_fog
				#include "UnityCG.cginc"
				
				struct v2f
				{
					float4 pos	: SV_POSITION;
					float2 uv 	: TEXCOORD0;
					float2 cap	: TEXCOORD1;
					UNITY_FOG_COORDS(2)
				};
				
				uniform float4 _MainTex_ST;
                float _NormalScale;

                float2 MatCapUV(in float3 N, float3 viewDir)
                {
					float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, N);
                    return viewNormal.xy * 0.5 + 0.5;
                }

                // UV校正版本1
				float2 MatCapUV2(in float3 N, float3 viewDir)
				{
					float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, N);
					 float3 viewPos = -mul(UNITY_MATRIX_V, viewDir);
                     float3 vTangent = normalize( cross(-viewPos,float3(0,1,0)));
                     float3 vBinormal  = cross( viewPos, vTangent  );
                     return float2( dot( vTangent , viewNormal ), dot( vBinormal  , viewNormal ) ) * 0.5 + 0.5;
				}

                // UV校正版本2
				float2 MatCapUV3(in float3 N,in float3 viewPos)
				{
					float3 viewNorm = -mul((float3x3)UNITY_MATRIX_V, N);
					float3 viewDir = normalize(viewPos);
					float3 viewCross = cross(viewDir, viewNorm);
					viewNorm = float3(-viewCross.y, viewCross.x, 0.0);
					float2 matCapUV = viewNorm.xy * 0.5 + 0.5;
					return matCapUV; 
				}
				
				v2f vert (appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					half2 capCoord;

                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
					
					float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
                    float3 viewDir = normalize(worldPos - _WorldSpaceCameraPos);

                    o.cap.xy = MatCapUV2(worldNorm, viewDir);
					
					UNITY_TRANSFER_FOG(o, o.pos);

					return o;
				}
				
				uniform sampler2D _MainTex;
				uniform sampler2D _MatCap;
				
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 tex = tex2D(_MainTex, i.uv);
					fixed4 mc = tex2D(_MatCap, i.cap) * tex;// * unity_ColorSpaceDouble;
					
					//UNITY_APPLY_FOG(i.fogCoord, mc);

					return mc;
				}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
