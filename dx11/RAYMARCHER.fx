//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 


float4x4 tVP : LAYERVIEWPROJECTION;	
float4x4 tVI: VIEWINVERSE;
float4x4 tW : WORLD;
float4x4 tPI : PROJECTIONINVERSE;

struct VS_IN
{
	float4 pos : POSITION;
	float4 uv : TEXCOORD0;

};

struct VS_OUT
{
    float4 pos: SV_Position;
    float4 uv: TEXCOORD0;
};

VS_OUT VS(VS_IN input)
{
    VS_OUT output;
    output.pos  = mul(input.pos,tW);
    output.uv = input.uv;
    return output;
}

struct GBuffer {
	float4 pos 	  : SV_Target0;
	float4 normal : SV_Target1;
//	float2 uv  	  : SV_Target2;
//	float  ao 	  : SV_Target3;
	float  depth  : SV_DEPTH;
};

struct vsm {
	float2 vsm 	  : SV_Target0;
	float  depth  : SV_DEPTH;
};

//float3 mouse;

	// Shapes
	//-------------------------------
	static const float3 myBox = float3(.2, 2, 2);
	//-------------------------------
	
float time;

float hash1( float n )
{
    return frac(sin(n)*43758.5453123);
}

float hash1( in float2 f ) 
{ 
    return frac(sin(f.x+131.1*f.y)*43758.5453123); 
}

static const float PI = 3.1415926535897932384626433832795;
static const float PHI = 1.6180339887498948482045868343656;

float3 UVtoEYE(float2 UV){
	return normalize( mul(float4(mul(float4((UV.xy*2-1)*float2(1,-1),0,1),tPI).xy,1,0),tVI).xyz);
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

//float smin( float a, float b, float k )
//{
//    float res = exp2( -k*a ) + exp2( -k*b );
//    return -log2( res )/k;
//}


float box (float3 p, float3 size){
	p = abs(p) - size;
	return max(p.x,max(p.y,p.z));
}

float plane (float3 p){
	return (p.y);
}

float sphere (float3 p){
	// Simple Sphere
	return (length(p) - 1.5 )*.1;
}

float sphere1 (float3 p){
	// Simple Sphere
	return (length(p) - 1 )*.1;
}

float sphereD (float3 p, float d){
	// Simple Sphere
	return (length(p) - d )*1;
}
	// Spherical UVs

	#define TWOPI 6.28318531
	#define PI 3.14159265
   float2 SphericalUV(float3 pos, float3 norm)
	{ 
		
	float2 result;
	float r;
	r = norm.x * norm.x + norm.y * norm.y + norm.z * norm.z;

	if (r > 0)
	{
		r = sqrt(r);
		float p, y;
		p = asin(norm.y/r) / TWOPI;
		y = 0;
		if (norm.z != 0) y = atan2(-norm.x, -norm.z);
		else if (norm.x > 0) y = -PI / 2;
       	else y = PI / 2;
		y /=  TWOPI;
		result = float2(-y,-(p+.25)*2);		
	}
	else result = 0;
	return result;
		
	}
   float2 CubicUV(float3 pos, float3 norm)
	{
		norm = float3(abs(norm.x), abs(norm.y), abs(norm.z));
		if (norm.x > norm.y && norm.x > norm.z)
		return float2(pos.z, -pos.y)+.5;
		else if (norm.y > norm.x && norm.y > norm.z)
		return float2(pos.x, -pos.z)+.5;
		else return float2(pos.x, -pos.y)+.5;
	}


float3 forwardSF( float i, float n) 
{
    float phi = 2.0*PI*frac(i/PHI);
    float zi = 1.0 - (2.0*i+1.0)/n;
    float sinTheta = sqrt( 1.0 - zi*zi);
    return float3( cos(phi)*sinTheta, sin(phi)*sinTheta, zi);
}

float3 opTwist( float3 p )
{
    float c = cos(4.0*p.y);
    float s = sin(2.0*p.y);
    float2x2  m = float2x2(c,-s,s,c);
    float3  q = float3(mul(m,p.xz),p.y);
//    return sin(q.xz*1).xyx + q;
	return q;
}

float fOpUnionStairs(float a, float b, float r, float n) 
{
	float s = r/n;
	float u = b-r;
	return min(min(a,b), 0.5 * (u + a + abs (( abs((u - a + s) % (2 * s))) - s)));
}


float fOpIntersectionStairs(float a, float b, float r, float n) 
{
	return -fOpUnionStairs(-a, -b, r, n);
}

float fOpIntersectionChamfer(float a, float b, float r) 
{
	return max(max(a, b), (a + r + b)*sqrt(0.5));
}


SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

Texture3D texVOL;
float2 ctrl;
StructuredBuffer <float4x4> transformVol;


float volume(float3 p, uint transformID){
		float result = texVOL.SampleLevel(linearSampler,mul( float4( (p.xyz*float3(1,1,1)), 1), transformVol[transformID]), 0).x;
		return result;
}

// Distance field function
float sceneSDF (float3 p)
{
//	float a = box(opTwist(p*2),float3(1,1,1))*.1;
//	float b = -box(p+mouse,myBox);
//	float b = sphereD(p+mouse,.5);
	
	float a = volume(p, 0);
	float b = volume(p, 1);
	
//	return fOpIntersectionStairs(a,b,.03,5);
//	return smin( fOpIntersectionChamfer(a,b,.005), box(p+float3(0,.5,0), float3(2,.1,2)),.3 );
	return smin( smin(a,b,.1), box(p+float3(0,.5,0), float3(1,.025,1)), .1) * .06;
//	return smin(a,b,.1	);
//	return fOpUnionStairs(a,b,.05,5);
//	return max( box(opTwist(p*2),float3(1,1,1))*.1,-box(p+mouse,myBox));



}

float calcAO( in float3 pos, in float3 nor)
{
	float ao = 0.0;
    for( int i=0; i<64; i++ )
    {
        float3 ap = forwardSF( float(i), 64.0 );
		  ap *= sign( dot(ap,nor) ) * hash1(float(i));
//        ao += clamp( sceneSDF( pos + nor*.3 + ap*.5 )*16.0, 0.0, 1.0 );
		  ao += clamp( sceneSDF( pos + nor*.1 + ap*.3 )*64.0, 0.0, 1.0 );
    }
	ao /= 64.0;
	
    return clamp( ao*ao, 0.0, 1.0 );
}

float3 calcNormal( in float3 pos )
{
	float3 eps = float3( 0.01, 0.0, 0.0 );
	float3 nor = float3(
	sceneSDF(pos+eps.xyy) - sceneSDF(pos-eps.xyy),
	sceneSDF(pos+eps.yxy) - sceneSDF(pos-eps.yxy),
	sceneSDF(pos+eps.yyx) - sceneSDF(pos-eps.yyx) );
	return normalize(nor);
}



static const float MAX_DIST = 10.0;
static const float EPSILON = .001;



float raymarch (in float3 eye, in float3 dir)
{
	float t = 0.0;
	float dist = .1;
	for (uint i = 0 ; i < 512 ; i++)
	{	
		if(dist < EPSILON || dist > MAX_DIST) break;
		dist = sceneSDF (eye + dir*t);
		t += dist * 0.5;
	}
	return t;

}


GBuffer PS(VS_OUT input)
{	
	
	GBuffer output;
	
//	uint mID = 0;
	float mID = 0;
	
//	float4 col = 0;
	float3 normal = 0;

	// Ray Origin
	float3 eye = tVI[3].xyz;

	// Ray Direction
	float3 dir = UVtoEYE(input.uv.xy);
	
	float edge = 0;
	float dist = raymarch(eye,dir);
	float3 p = eye + dist * dir;
	
	// Avoid artifacts for infinite distances
//	if(abs(sceneSDF (eye + dir)) > .5) discard;
	if(dist>MAX_DIST) discard;
 	if(dist<MAX_DIST) normal = calcNormal(p);
	

	float3 p1 = p;	
	
	float x = 1;
	//Domain Distortion
	p1.xyz += 1.000 * x * sin(  2.0  * p1.yzx +time		    * 1 );
    p1.xyz += 0.500 * x * sin(  4.0  * p1.yzx -time * 15.1  * 1 );
    p1.xyz += 0.250 * x * sin(  8.0  * p1.yzx +time * 10.2  * 1 );
    p1.xyz += 0.050 * x * sin( 16.0  * p1.yzx -time * 14.3  * 1 );
	
	
	if( sphere(p1) < .001 ){
		 mID = 1;
	}
	else{
		mID = 0;
	}
	
	float4 PosWVP = mul(float4(p.xyz,1),tVP);
	
	output.pos = float4(p.xyz,1);
	output.normal = float4(normal, (float) mID * .001 ); //.001
		
//	output.uv = CubicUV(p.xyz, normal);
//	output.uv = 0;
	output.depth = PosWVP.z/PosWVP.w;
	

	
	return output;
}

float3 lightPos;
float  lightRange;

vsm PS_VSM(VS_OUT input)
{	
	vsm output;
	uint mID = 0;
	
//	float4 col = 0;
	float3 normal = 0;

	// Ray Origin
	float3 eye = tVI[3].xyz;

	// Ray Direction
	float3 dir = UVtoEYE(input.uv.xy);
	
	float edge = 0;
	float dist = raymarch(eye,dir);
	float3 p = eye + dist * dir;
	
	// Avoid artifacts for infinite distances
//	if(abs(sceneSDF (eye + dir)) > .5) discard;
	if(dist>MAX_DIST) discard;
 	if(dist<MAX_DIST) normal = calcNormal(p);
	
	float worldSpaceDistance = distance(lightPos, p.xyz);
	float2 vsm;
	vsm.x = (worldSpaceDistance / lightRange) + .01;
	vsm.y = vsm.x * vsm.x;
	
	output.vsm = vsm;
	
	float4 PosWVP = mul(float4(p.xyz,1),tVP);
	output.depth = PosWVP.z/PosWVP.w;
	return output;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}

technique10 VSM
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_VSM() ) );
	}
}





