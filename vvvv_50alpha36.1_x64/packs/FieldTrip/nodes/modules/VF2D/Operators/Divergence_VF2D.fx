
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Divergence Scalar from 2D Vector Field Function
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY

#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh>
#endif


// Input VF2D function placeholder
#ifndef FN_INPUT
#define FN_INPUT normalize
#endif

// Parameters
float FN_eps : FN_EPS = 0.01;

float FN_ (float2 p)
{
	return calcDivV2(FN_INPUT, p, FN_eps);
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef SF2D
#define SF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

