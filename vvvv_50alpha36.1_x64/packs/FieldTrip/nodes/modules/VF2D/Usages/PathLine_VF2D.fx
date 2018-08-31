#ifndef CALC_FXH
#include <packs\happy.fxh\calc.fxh>
#endif

#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// Input placeholder
#ifndef VF2D
#define VF2D normalize
#endif
////////////////////////////////////////////////////////////////////////////////////////////////
// integration method selector
    #if (INTEGRATIONMODE==1) 
	#define integrate calcRK2V2
	#elif (INTEGRATIONMODE==2) 
	#define integrate calcRK4V2
	#else 
	#define integrate calcEulerV2
	#endif




uint threadCount;
StructuredBuffer<float2> bPos <string uiname="Seed Position 2D Buffer";>;
RWStructuredBuffer<float2> Output : BACKBUFFER;

uint pathSize <string uiname="Points Per Path";> = 32;
float maxDist <string uiname="Maximum Distance from Seed Position";> = 5;

float stepSizeDefault <string uiname="Step Size Defualt";> = 0.01666;
StructuredBuffer<float> stepSizeBuffer <string uiname="Step Size Buffer";>;

float resetAll <string uiname="Reset All";>;
StructuredBuffer<float> resetBuffer <string uiname="Reset Buffer";>;


//GROUPSIZE
[numthreads(64, 1, 1)]
void CS_PathLine( uint3 dtid : SV_DispatchThreadID )
{

	if (dtid.x >= threadCount) { return; }
	uint pathIndex = dtid.x % pathSize;
	uint seedIndex = floor(dtid.x / pathSize);
	
	float reset = max(resetAll, resetBuffer[seedIndex % sbSize(resetBuffer)]);
	
	if (pathIndex != 0) // not leader
	{
		uint leaderIndex = dtid.x - pathIndex;
		if (reset || maxDist < distance(Output[leaderIndex], bPos[seedIndex])) 
		Output[dtid.x] = bPos[seedIndex];
		else 
		Output[dtid.x] = Output[dtid.x-1];
	}
	
	else // leader
	{
		if (reset || maxDist < distance(Output[dtid.x], bPos[seedIndex])) 
		Output[dtid.x] = bPos[seedIndex];
		else 
		{
			float stepSize = sbLoad(stepSizeBuffer, stepSizeDefault, dtid.x);
			integrate(VF2D, Output[dtid.x], stepSize);
		}
	}
	




}


technique11 PathLine
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_PathLine() ) );
	}
}

