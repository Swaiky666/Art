// Made with Amplify Shader Editor v1.9.9.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_Texture1( "Texture 1", 2D ) = "white" {}
		_Normal( "Normal", 2D ) = "white" {}
		_waveOffset( "waveOffset", Float ) = 0.001
		_waterRipple( "waterRipple", 2D ) = "white" {}
		_RippleValue( "RippleValue", Range( 1, 5 ) ) = 100
		_RippleColor( "RippleColor", Color ) = ( 0, 0, 0, 0 )
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
		#define ASE_VERSION 19905
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform sampler2D _waterRipple;
		uniform float4 _waterRipple_ST;
		uniform float _RippleValue;
		uniform float _waveOffset;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float4 _RippleColor;
		uniform sampler2D _Texture1;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (2.0).xx;
			float mulTime75 = _Time.y * 0.03;
			float2 temp_cast_1 = (mulTime75).xx;
			float2 uv_TexCoord71 = v.texcoord.xy * temp_cast_0 + temp_cast_1;
			float2 temp_cast_2 = (1.0).xx;
			float mulTime93 = _Time.y * 0.05;
			float mulTime95 = _Time.y * 0.06;
			float4 appendResult92 = (float4(mulTime93 , mulTime95 , 0.0 , 0.0));
			float2 uv_TexCoord90 = v.texcoord.xy * temp_cast_2 + appendResult92.xy;
			float2 uv_waterRipple = v.texcoord * _waterRipple_ST.xy + _waterRipple_ST.zw;
			float smoothstepResult131 = smoothstep( 0.0 , 2.0 , saturate( pow( tex2Dlod( _waterRipple, float4( uv_waterRipple, 0, 0.0) ).r , 0.24 ) ));
			float smoothstepResult101 = smoothstep( 0.0 , 1.0 , saturate( ( tex2Dlod( _Normal, float4( uv_TexCoord71, 0, 0.0) ).r * ( ( tex2Dlod( _Normal, float4( uv_TexCoord90, 0, 0.0) ).r * 2.0 ) + ( smoothstepResult131 * _RippleValue ) ) ) ));
			float3 ase_normalOS = v.normal.xyz;
			v.vertex.xyz += ( ( smoothstepResult101 * _waveOffset ) * ase_normalOS );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color9 = IsGammaSpace() ? float4( 0.06666669, 0.6886879, 0.7529412, 0.5019608 ) : float4( 0.005605394, 0.4320479, 0.5271152, 0.5019608 );
			float4 color10 = IsGammaSpace() ? float4( 0.06274509, 0.4428188, 0.6235294, 0.7607843 ) : float4( 0.005181515, 0.164879, 0.3467041, 0.7607843 );
			float4 ase_positionSS = float4( i.screenPos.xyz , i.screenPos.w + 1e-7 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float screenDepth19 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth19 = ( screenDepth19 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( 0.65 );
			float temp_output_25_0 = saturate( distanceDepth19 );
			float4 lerpResult8 = lerp( color9 , color10 , temp_output_25_0);
			float4 lerpResult45 = lerp( lerpResult8 , ( lerpResult8 * ( 1.0 - 0.2 ) ) , float4( 0,0,0,0 ));
			float2 temp_cast_1 = (2.0).xx;
			float mulTime75 = _Time.y * 0.03;
			float2 temp_cast_2 = (mulTime75).xx;
			float2 uv_TexCoord71 = i.uv_texcoord * temp_cast_1 + temp_cast_2;
			float2 temp_cast_3 = (1.0).xx;
			float mulTime93 = _Time.y * 0.05;
			float mulTime95 = _Time.y * 0.06;
			float4 appendResult92 = (float4(mulTime93 , mulTime95 , 0.0 , 0.0));
			float2 uv_TexCoord90 = i.uv_texcoord * temp_cast_3 + appendResult92.xy;
			float2 uv_waterRipple = i.uv_texcoord * _waterRipple_ST.xy + _waterRipple_ST.zw;
			float smoothstepResult131 = smoothstep( 0.0 , 2.0 , saturate( pow( tex2D( _waterRipple, uv_waterRipple ).r , 0.24 ) ));
			float smoothstepResult101 = smoothstep( 0.0 , 1.0 , saturate( ( tex2D( _Normal, uv_TexCoord71 ).r * ( ( tex2D( _Normal, uv_TexCoord90 ).r * 2.0 ) + ( smoothstepResult131 * _RippleValue ) ) ) ));
			float4 lerpResult126 = lerp( ( lerpResult45 + float4( 0,0,0,0 ) ) , float4( _RippleColor.rgb , 0.0 ) , pow( ( smoothstepResult101 * 2.0 ) , 2.0 ));
			o.Albedo = lerpResult126.rgb;
			float4 temp_cast_6 = (temp_output_25_0).xxxx;
			float2 temp_cast_7 = (4.0).xx;
			float mulTime56 = _Time.y * 0.02;
			float2 temp_cast_8 = (mulTime56).xx;
			float2 uv_TexCoord52 = i.uv_texcoord * temp_cast_7 + temp_cast_8;
			o.Emission = step( temp_cast_6 , tex2D( _Texture1, uv_TexCoord52 ) ).rgb;
			o.Alpha = pow( ( temp_output_25_0 * 1.5 ) , 0.4 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback Off
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19905
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;94;400,-784;Inherit;False;Constant;_Float9;Float 9;4;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;96;368,-688;Inherit;False;Constant;_Float10;Float 9;4;0;Create;True;0;0;0;False;0;False;0.06;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;1296,-16;Inherit;True;Property;_waterRipple;waterRipple;4;0;Create;True;0;0;0;False;0;False;3c7670464f48f4cdfb58822cb2f178d6;3c7670464f48f4cdfb58822cb2f178d6;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;93;608,-768;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;95;576,-672;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;1504,-32;Inherit;True;Property;_TextureSample4;Texture Sample 4;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;89;832,-848;Inherit;False;Constant;_Float8;Float 6;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;92;800,-720;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;132;1808,32;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.24;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;90;1024,-768;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;77;288,-1008;Inherit;False;Constant;_Float7;Float 7;4;0;Create;True;0;0;0;False;0;False;0.03;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;130;1984,32;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;91;1344,-656;Inherit;True;Property;_TextureSample3;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;1504,-368;Inherit;False;Constant;_Float11;Float 11;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;496,-1008;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;74;816,-1008;Inherit;False;Constant;_Float6;Float 6;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;125;1936,352;Inherit;False;Property;_RippleValue;RippleValue;5;0;Create;True;0;0;0;False;0;False;100;1.5;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;131;2144,16;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;62;1136,-1200;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;91567e4ffe4db49afa5c65e9bb12875f;91567e4ffe4db49afa5c65e9bb12875f;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;71;1040,-992;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;97;1648,-608;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;124;2336,-96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;21;-16,-128;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0.65;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;63;1360,-880;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;110;1936,-480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;19;160,-160;Inherit;False;True;False;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;43;784,144;Inherit;False;Constant;_DetailDarken;DetailDarken;1;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;1920,-816;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;57;-32,800;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;10;384,-624;Inherit;False;Constant;_DeepWater;DeepWater;2;0;Create;True;0;0;0;False;0;False;0.06274509,0.4428188,0.6235294,0.7607843;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;9;704,-624;Inherit;False;Constant;_ShalloowWater;ShalloowWater;2;0;Create;True;0;0;0;False;0;False;0.06666669,0.6886879,0.7529412,0.5019608;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;44;1008,144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;25;464,-176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;2128,-736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;208,576;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;192,784;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;42;1280,-208;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;8;1008,-448;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;2224,-656;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;30;704,-96;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;51;336,352;Inherit;True;Property;_Texture1;Texture 1;0;0;Create;True;0;0;0;False;0;False;bb46e3902e2ff4c88805aeb19cd44c02;bb46e3902e2ff4c88805aeb19cd44c02;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;432,640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;85;2368,-816;Inherit;False;Property;_waveOffset;waveOffset;3;0;Create;True;0;0;0;False;0;False;0.001;0.003;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;45;1664,-304;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;129;2464,-416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;26;848,-176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;29;880,-48;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;49;720,400;Inherit;True;Global;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;bb46e3902e2ff4c88805aeb19cd44c02;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;88;2800,-448;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;84;2640,-896;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;2256,-352;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;127;2256,128;Inherit;False;Property;_RippleColor;RippleColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6719473,0.8852286,0.9433962,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;128;2512,-256;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;73;816,-1584;Inherit;False;Constant;_Float5;Float 5;4;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;72;1104,-1440;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;68;1104,-1712;Inherit;True;Property;_Normal2;Normal2;2;0;Create;True;0;0;0;False;0;False;None;3f1438e8fedfc40e0af0f1d3939970c8;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;78;1506.352,-1150.889;Inherit;False;Normal From Texture;-1;;1;9728ee98a55193249b513caf9a0f1676;13,149,0,147,0,143,0,141,0,139,0,151,0,137,0,153,0,159,0,157,0,155,0,135,0,108,0;4;87;SAMPLER2D;0;False;85;FLOAT2;0,0;False;74;SAMPLERSTATE;0;False;91;FLOAT;1.5;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;69;1600,-1520;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;50;1344,240;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;86;1995.874,-1099.055;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;27;1056,-96;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;87;3040,-576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;126;2944,-272;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;3408,-240;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;0;Standard;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;93;0;94;0
WireConnection;95;0;96;0
WireConnection;109;0;108;0
WireConnection;92;0;93;0
WireConnection;92;1;95;0
WireConnection;132;0;109;1
WireConnection;90;0;89;0
WireConnection;90;1;92;0
WireConnection;130;0;132;0
WireConnection;91;0;62;0
WireConnection;91;1;90;0
WireConnection;75;0;77;0
WireConnection;131;0;130;0
WireConnection;71;0;74;0
WireConnection;71;1;75;0
WireConnection;97;0;91;1
WireConnection;97;1;99;0
WireConnection;124;0;131;0
WireConnection;124;1;125;0
WireConnection;63;0;62;0
WireConnection;63;1;71;0
WireConnection;110;0;97;0
WireConnection;110;1;124;0
WireConnection;19;0;21;0
WireConnection;98;0;63;1
WireConnection;98;1;110;0
WireConnection;44;0;43;0
WireConnection;25;0;19;0
WireConnection;100;0;98;0
WireConnection;56;0;57;0
WireConnection;42;0;8;0
WireConnection;42;1;44;0
WireConnection;8;0;9;0
WireConnection;8;1;10;0
WireConnection;8;2;25;0
WireConnection;101;0;100;0
WireConnection;52;0;53;0
WireConnection;52;1;56;0
WireConnection;45;0;8;0
WireConnection;45;1;42;0
WireConnection;129;0;101;0
WireConnection;26;0;25;0
WireConnection;26;1;30;0
WireConnection;49;0;51;0
WireConnection;49;1;52;0
WireConnection;84;0;101;0
WireConnection;84;1;85;0
WireConnection;113;0;45;0
WireConnection;128;0;129;0
WireConnection;72;0;73;0
WireConnection;72;1;75;0
WireConnection;78;87;62;0
WireConnection;78;85;71;0
WireConnection;69;0;68;0
WireConnection;69;1;72;0
WireConnection;50;0;25;0
WireConnection;50;1;49;0
WireConnection;86;0;78;40
WireConnection;86;1;69;0
WireConnection;27;0;26;0
WireConnection;27;1;29;0
WireConnection;87;0;84;0
WireConnection;87;1;88;0
WireConnection;126;0;113;0
WireConnection;126;1;127;5
WireConnection;126;2;128;0
WireConnection;0;0;126;0
WireConnection;0;2;50;0
WireConnection;0;9;27;0
WireConnection;0;11;87;0
ASEEND*/
//CHKSM=C89444D975264D928A2EF8870409D2A88A251B43