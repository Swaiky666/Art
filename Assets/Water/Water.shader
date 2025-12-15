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
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.5
		#define ASE_VERSION 19905
		#pragma surface surf Standard alpha:fade keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float _waveOffset;
		uniform sampler2D _Normal;
		uniform sampler2D _waterRipple;
		uniform float4 _waterRipple_ST;
		uniform float _RippleValue;
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
			float2 uv_waterRipple = v.texcoord * _waterRipple_ST.xy + _waterRipple_ST.zw;
			float smoothstepResult131 = smoothstep( 0.0 , 2.0 , saturate( pow( tex2Dlod( _waterRipple, float4( uv_waterRipple, 0, 0.0) ).r , 0.24 ) ));
			float2 temp_cast_2 = (1.0).xx;
			float mulTime93 = _Time.y * 0.05;
			float2 temp_cast_3 = (mulTime93).xx;
			float2 uv_TexCoord90 = v.texcoord.xy * temp_cast_2 + temp_cast_3;
			float smoothstepResult101 = smoothstep( 0.0 , 1.0 , saturate( ( tex2Dlod( _Normal, float4( uv_TexCoord71, 0, 0.0) ).r * ( ( smoothstepResult131 * _RippleValue ) + ( 2.0 * tex2Dlod( _Normal, float4( uv_TexCoord90, 0, 0.0) ).r ) ) ) ));
			float3 ase_normalOS = v.normal.xyz;
			v.vertex.xyz += ( ( _waveOffset * smoothstepResult101 ) * ase_normalOS );
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
			float2 uv_waterRipple = i.uv_texcoord * _waterRipple_ST.xy + _waterRipple_ST.zw;
			float smoothstepResult131 = smoothstep( 0.0 , 2.0 , saturate( pow( tex2D( _waterRipple, uv_waterRipple ).r , 0.24 ) ));
			float2 temp_cast_3 = (1.0).xx;
			float mulTime93 = _Time.y * 0.05;
			float2 temp_cast_4 = (mulTime93).xx;
			float2 uv_TexCoord90 = i.uv_texcoord * temp_cast_3 + temp_cast_4;
			float smoothstepResult101 = smoothstep( 0.0 , 1.0 , saturate( ( tex2D( _Normal, uv_TexCoord71 ).r * ( ( smoothstepResult131 * _RippleValue ) + ( 2.0 * tex2D( _Normal, uv_TexCoord90 ).r ) ) ) ));
			float4 lerpResult126 = lerp( ( lerpResult45 + float4( 0,0,0,0 ) ) , float4( _RippleColor.rgb , 0.0 ) , pow( ( smoothstepResult101 * 2.0 ) , 2.0 ));
			o.Albedo = lerpResult126.rgb;
			float4 temp_cast_6 = (temp_output_25_0).xxxx;
			float2 temp_cast_7 = (4.0).xx;
			float mulTime56 = _Time.y * 0.02;
			float2 temp_cast_8 = (mulTime56).xx;
			float2 uv_TexCoord52 = i.uv_texcoord * temp_cast_7 + temp_cast_8;
			o.Emission = step( temp_cast_6 , tex2D( _Texture1, uv_TexCoord52 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback Off
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19905
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;136;-144,-2096;Inherit;False;1281.824;368.2017;**Convert dynamically generated ripples from a hidden interaction camera into a dynamic texture.** ;7;124;125;131;130;132;109;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;135;-128,-1520;Inherit;False;2210.596;799.5394;**From a black-and-white water ripple texture, generate interlaced dynamic base water waves.** ;12;98;63;71;62;91;75;74;77;94;93;89;90;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;-112,-1984;Inherit;True;Property;_waterRipple;waterRipple;3;0;Create;True;0;0;0;False;0;False;3c7670464f48f4cdfb58822cb2f178d6;3c7670464f48f4cdfb58822cb2f178d6;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;96,-1984;Inherit;True;Property;_TextureSample4;Texture Sample 4;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;94;-64,-1344;Inherit;False;Constant;_Float9;Float 9;4;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;132;400,-2032;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.24;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;93;160,-1344;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;89;336,-1424;Inherit;False;Constant;_Float8;Float 6;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;130;544,-2032;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;138;1200,-2096;Inherit;False;652.9706;536.4329;**Combine the two to produce real-time ripples.** ;3;110;97;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;77;-96,-864;Inherit;False;Constant;_Float7;Float 7;4;0;Create;True;0;0;0;False;0;False;0.03;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;90;512,-1392;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;131;688,-2032;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;125;592,-1888;Inherit;False;Property;_RippleValue;RippleValue;4;0;Create;True;0;0;0;False;0;False;100;1.5;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;74;256,-960;Inherit;False;Constant;_Float6;Float 6;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;112,-864;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;91;832,-1376;Inherit;True;Property;_TextureSample3;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;1232,-1856;Inherit;False;Constant;_Float11;Float 11;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;124;960,-1952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;71;480,-944;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;62;448,-1200;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;91567e4ffe4db49afa5c65e9bb12875f;91567e4ffe4db49afa5c65e9bb12875f;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;97;1392,-1824;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;140;-112,-592;Inherit;False;1627.652;512.5646;**Use depth fade to control the color of shallow and deep water.** ;7;45;42;8;44;10;9;43;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;21;-80,16;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0.65;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;63;832,-976;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;110;1584,-1952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;139;-96,192;Inherit;False;1622.684;672.1328;**Use depth fade to remove foam farther from the shoreline.** ;7;50;49;51;52;56;53;57;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;43;624,-208;Inherit;False;Constant;_DetailDarken;DetailDarken;1;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;19;112,0;Inherit;False;True;False;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;1824,-1184;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;57;96,736;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;2192,-976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;9;144,-544;Inherit;False;Constant;_ShalloowWater;ShalloowWater;2;0;Create;True;0;0;0;False;0;False;0.06666669,0.6886879,0.7529412,0.5019608;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;10;144,-336;Inherit;False;Constant;_DeepWater;DeepWater;2;0;Create;True;0;0;0;False;0;False;0.06274509,0.4428188,0.6235294,0.7607843;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;44;800,-208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;25;400,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;336,512;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;320,720;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;2304,-848;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;8;576,-432;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;42;1072,-272;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;129;2544,-640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;560,576;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;85;2464,-1072;Inherit;False;Property;_waveOffset;waveOffset;2;0;Create;True;0;0;0;False;0;False;0.001;0.003;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;51;448,272;Inherit;True;Property;_Texture1;Texture 1;0;0;Create;True;0;0;0;False;0;False;bb46e3902e2ff4c88805aeb19cd44c02;bb46e3902e2ff4c88805aeb19cd44c02;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;45;1328,-336;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;88;2976,-832;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;84;2672,-960;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;127;2752,-704;Inherit;False;Property;_RippleColor;RippleColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6719473,0.8852286,0.9433962,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;128;2768,-480;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;49;848,336;Inherit;True;Global;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;bb46e3902e2ff4c88805aeb19cd44c02;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;2416,-320;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;50;1312,240;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;126;3168,-368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;87;3248,-960;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;3856,-448;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;0;Standard;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;109;0;108;0
WireConnection;132;0;109;1
WireConnection;93;0;94;0
WireConnection;130;0;132;0
WireConnection;90;0;89;0
WireConnection;90;1;93;0
WireConnection;131;0;130;0
WireConnection;75;0;77;0
WireConnection;91;0;62;0
WireConnection;91;1;90;0
WireConnection;124;0;131;0
WireConnection;124;1;125;0
WireConnection;71;0;74;0
WireConnection;71;1;75;0
WireConnection;97;0;99;0
WireConnection;97;1;91;1
WireConnection;63;0;62;0
WireConnection;63;1;71;0
WireConnection;110;0;124;0
WireConnection;110;1;97;0
WireConnection;19;0;21;0
WireConnection;98;0;63;1
WireConnection;98;1;110;0
WireConnection;100;0;98;0
WireConnection;44;0;43;0
WireConnection;25;0;19;0
WireConnection;56;0;57;0
WireConnection;101;0;100;0
WireConnection;8;0;9;0
WireConnection;8;1;10;0
WireConnection;8;2;25;0
WireConnection;42;0;8;0
WireConnection;42;1;44;0
WireConnection;129;0;101;0
WireConnection;52;0;53;0
WireConnection;52;1;56;0
WireConnection;45;0;8;0
WireConnection;45;1;42;0
WireConnection;84;0;85;0
WireConnection;84;1;101;0
WireConnection;128;0;129;0
WireConnection;49;0;51;0
WireConnection;49;1;52;0
WireConnection;113;0;45;0
WireConnection;50;0;25;0
WireConnection;50;1;49;0
WireConnection;126;0;113;0
WireConnection;126;1;127;5
WireConnection;126;2;128;0
WireConnection;87;0;84;0
WireConnection;87;1;88;0
WireConnection;0;0;126;0
WireConnection;0;2;50;0
WireConnection;0;11;87;0
ASEEND*/
//CHKSM=2EBB5452449B84228169D1384CE9E4F54EEB4290