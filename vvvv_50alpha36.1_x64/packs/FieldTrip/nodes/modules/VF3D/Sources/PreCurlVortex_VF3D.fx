
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Pre Curl Vortex Function
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY

#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh>
#endif

// Parameters
float3 FN_direction : FN_DIRECTION = float3(1.0, 0.0, 0.0);
float3 FN_pos : FN_POS;
float FN_radius : FN_RADIUS = 0.15;
	
float3 FN_ (float3 p)
{
	return preCurlVortex(p, FN_pos, FN_direction, FN_radius);
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef VF3D
#define VF3D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////


technique11 RemoveMe{}

