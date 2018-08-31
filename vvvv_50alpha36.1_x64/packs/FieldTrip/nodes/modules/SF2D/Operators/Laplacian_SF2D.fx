#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh>
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Laplacian from a 2D Scalar Field 
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY


// Parameters
float FN_epsilon : FN_EPSILON = 0.01;

// Input function placeholder
#ifndef FN_INPUT
#define FN_INPUT placeHolderS2
#endif


float FN_ (float2 p)
{
	return calcLapS2(FN_INPUT, p, FN_epsilon);
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef SF2D
#define SF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

