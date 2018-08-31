
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		2D vector Domain Lookup Function
//
////////////////////////////////////////////////////////////////////////////////////////////////
// This token will be replaced with function name via RegExpr: "FN_"

// ensures the function is defined only once per instance
#ifndef FN_BODY 
#define FN_BODY



// Input VF2D function placeholder
#ifndef FN_INPUT
#define FN_INPUT normalize
#endif

// Input VF2D function placeholder
#ifndef FN_DISTORTION
#define FN_DISTORTION normalize
#endif

float2 FN_ (float2 p)
{
	p = FN_DISTORTION(p);
	return FN_INPUT(p);
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef VF2D
#define VF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////

technique11 RemoveMe{}
