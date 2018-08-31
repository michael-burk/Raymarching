
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Laplacian Vector from a 2D Vector Field Function
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY

#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh>
#endif

// Input VF2D Function placeholder
#ifndef FN_INPUT
#define FN_INPUT normalize
#endif

// Parameters
float FN_eps : FN_EPS = 0.01;

float2 FN_ (float2 p)
{
	return calcLapV2(FN_INPUT, p, FN_eps);
	
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef VF2D
#define VF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

