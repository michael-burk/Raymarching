
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		2D Scalar Field Texture Sample Function
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY
// DEFINES

#ifndef UV_FXH
#include <packs\happy.fxh\uv.fxh>
#endif
  
// Parameters
float4x4 FN_InvMat : FN_INVMAT =  { 1, 0, 0,  0, 
 									0, 1, 0,  0, 
 									0, 0, 1,  0, 
  									0, 0, 0,  1  };
Texture2D FN_vfTex : FN_VFTEX;
SamplerState FN_Samp : Immutable
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 
float FN_ (float2 p)
{
	p = mul(float4(p, 0, 1), FN_InvMat).xy; 
	p.y = -p.y;
	p += .5;
	#if FN_NOTILE == 1
	float v = sampleNoTile(FN_vfTex, p, FN_Samp).x;
	#else
	float v = FN_vfTex.SampleLevel(FN_Samp, p, 0).x;
	#endif
	return v;
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef SF2D
#define SF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

