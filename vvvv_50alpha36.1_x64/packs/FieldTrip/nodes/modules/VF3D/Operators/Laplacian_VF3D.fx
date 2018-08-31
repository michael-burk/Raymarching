
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Laplacian Vector from a 3D Vector Field Function
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY

#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh>
#endif

// Input VF3D Function placeholder
#ifndef FN_INPUT
#define FN_INPUT normalize
#endif

// Parameters
float FN_eps : FN_EPS = 0.01;

float3 FN_ (float3 p)
{
	return calcLapV3(FN_INPUT, p, FN_eps);
	
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef VF3D
#define VF3D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

