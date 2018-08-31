
////////////////////////////////////////////////////////////////////////////////////////////////
//
//		2D Vector FBM Fractal Sum
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

// DEFINES
#ifndef NOISE_FXH
#include <packs\happy.fxh\noise.fxh>
#endif

// parameters
float FN_persistence : FN_PERSISTENCE = 0.5;  
float FN_lacunarity : FN_LACUNARITY = 2;    
int FN_octaves: FN_OCTAVES = 4;  



float2 FN_ (float2 p)
{
	FBM2(FN_noise, FN_INPUT, p, FN_persistence, FN_lacunarity, FN_octaves);    
	return FN_noise;
}
// end of the function body
#endif 

////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef VF2D
#define VF2D FN_
#endif
////////////////////////////////////////////////////////////////////////////////////////////////



technique11 RemoveMe{}

