
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Mandelbox Fractal Distance Field
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY

#ifndef SDF_FXH
#include <packs\happy.fxh\sdf.fxh>
#endif

// Parameters
float FN_MinRad2 : FN_MINRAD2;
float FN_Scale : FN_SCALE;
float3 FN_Trans : FN_TRANS; 
float3 FN_Julia : FN_JULIA; 
float3 FN_PYR : FN_ROT;
int FN_iter : FN_ITER;


float FN_(float3 p)
{
	return fMandelbox(p, FN_MinRad2, FN_Scale, FN_Trans, FN_Julia, FN_PYR, FN_iter);
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef SF3D
#define SF3D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////

technique11 RemoveMe{}

