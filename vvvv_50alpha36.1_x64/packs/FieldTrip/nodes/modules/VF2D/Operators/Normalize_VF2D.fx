
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Normalize a 2D Vector Field 
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY

// Input Function VF2D placeholder
#ifndef FN_INPUT
#define FN_INPUT normalize
#endif


float2 FN_ (float2 p)
{
	return normalize(FN_INPUT(p));
}
// end of the function body
#endif 

#ifndef VF2D
#define VF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

