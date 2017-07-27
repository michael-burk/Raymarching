//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits:

Texture3D texVOL <string uiname="Volume";>;
#include <packs\InstanceNoodles\nodes\modules\Common\NoodleNoise.fxh>
iFractalNoise fractalType <string linkclass="Noise,FBM,Turbulence,Ridge";>;
iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;
float freq, pers, lacun;
int oct;


float4 control;
SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};
	float4x4 tVP : LAYERVIEWPROJECTION;	
	float4x4 tVI: VIEWINVERSE;
	float4x4 tW : WORLD;
	float4x4 tPI : PROJECTIONINVERSE;

Texture2D depth;
float2 ctrl;
float3 ctrl2;
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

float3 mouse;



float mod(float x, float y)
{
  return x - y * floor(x/y);
}
float3 mod3(float3 x, float3 y)
{
  return x - y * floor(x/y);
}
float3 mirror(float3 p, float v) {
  float hv = v * 0.5;
  float3  fl = mod3(floor(p / v + 0.5), 2.0) * 2.0 - 1.0;
  float3  mp = mod3(p + hv, v) - hv;
    
  return fl * mp;
}

float pMod1(inout float p, float size){
	
	float halfsize = size*.5;
	float c = floor((p+halfsize)/size);
	
	p = mod(p.x+halfsize,size) - halfsize;
	return c;
}

float3 UVtoEYE(float2 UV){
	return normalize( mul(float4(mul(float4((UV.xy*2-1)*float2(1,-1),0,1),tPI).xy,1,0),tVI).xyz);
}

// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

float box (float3 p, float3 size){
//	p = 1 - frac(p)*2;
//	p = abs(p) - float3(.05,.5,.05)+  (sin(10*p.x)*sin(10*p.y)*sin(10*p.z))*.03;
	p = abs(p) - size;
	return max(p.x,max(p.y,p.z));
}

float plane (float3 p){
	return (p.y);
}

float sphere (float3 p, float radius){

	//Repeat
	//p = 1 - frac(p)*2;

	// Displaced Sphere + Mouse
//	p+=mouse;
//	return (length(p+mouse) - .5 ) +  (sin(10*p.x)*sin(10*p.y)*sin(10*p.z))*.1;

	// Simple Sphere
	return (length(p) - radius );
}
float sphereRepeat (float3 p, float radius){

	//Repeat
	p = 1 - frac(p)*2;
	
	// Simple Sphere
	return (length(p) - radius );
}
float model(float3 p){
//	p.xz = 1 - frac(p.xz)*2;


	float c = pMod1(p.x,2);
	p.y +=sin(c);
	
//		p.y -= sin(c/2)*2;
	

	return (length(p) - 1.0 + abs(c)*.1)*.1;
}


float depthTex(float3 p){
	return -p.z  + (depth.SampleLevel(linearSampler,p.xy*float2(1,-1)*.25+.5,0).r);
}


float volume(float3 p){
//		p.xyz = p.xyz ;
//	    p = p*2048 + 0.5;
//	
//	    float3 i = floor(p);
//	    float3 f = p - i;
//	    f = f*f*f*(f*(f*6.0-15.0)+10.0);
//	    p = i + f;
//	
//	    p = (p - 0.5)/2048;
//	    return texture2D( myTex, p );
	
		return texVOL.SampleLevel(linearSampler,float3((p.xyz*ctrl.x+ctrl.y)),0).x;
//		return lerp(texVOL.SampleLevel(linearSampler,float3((p.xyz*ctrl.x+ctrl.y)),0).x, texVOL.SampleLevel(linearSampler,float3((p.xyz*ctrl.x+ctrl.y+float3(.01,.01,.01))),0).x,ctrl2.x);
}

//float hash1( float n )
//{
//    return frac(sin(n)*43758.5453123);
//}

float hash1( in float2 f ) 
{ 
    return frac(sin(f.x+131.1*f.y)*43758.5453123); 
}


float time;
// Distance field function
float sceneSDF (float3 p)
{
//	float3 p1 = p;
//	return lerp(box(p),sphere(p),.5);

//	return smin(box(p),sphere(p),.2);

//	return max(box(p),sphere(p));

	//Domain Distortion
//	p1.xyz += 1.000*sin(  2.0*p1.yzx +time)*.9;
// 	p1.xyz += 0.500*sin(  4.0*p1.yzx -time*15.1)*.9;
// 	p1.xyz += 0.250*sin(  8.0*p1.yzx +time*10.2)*.9;
// 	p1.xyz += 0.050*sin( 16.0*p1.yzx -time*14.3)*.9;


	// Intersect Chamfer
//	float a = sphere(p+mouse);
//	float b = sphere(p1);
//	float r = .1;
//
//	return max(max(a, b), (a + r + b)*sqrt(0.5));
	
	// Difference Chamfer
//	float a = sphere(p+mouse,2);
//	float b = sphere(p1,2);
//	float r = .1;
//	return max(max(a, -b), (a + r - b)*sqrt(0.5));
	
	// Combine
//	return smin(sphere(p+mouse),sphere(p1),.2);

	//Pipe
//	float a = box(p,float3(1.0,1.2,1.0));
//	float b = box(p,float3(1,1,1));
//	float r = .1;
//	return length(float2(a, b)) - r;

	//Depth Tex
//	return smin(sphere(p1+mouse),depthTex(p),.2);
//	return depthTex(p);

	//Modeling with distance functions
//	return model(p);

	//Volume Marching
//float a = box(p+mouse,.5);
//float b = volume(p);
//float r = .02;
//return max(max(a, -b), (a + r - b)*sqrt(0.5));
//	return max(sphere(p1+mouse,.5),volume(p));
//	return max(box(p+mouse,.5),volume(p));
//	return volume(p);

//	p += fractalType.Worley(Euclidean, F1, p, freq, pers, lacun, 1);
//	p += volume(p*.5)*.1;
	// Molecuar
	// Difference
//	float a = sphere(p,1.01);
//	float b = sphere(p,1);
//	float r = .001;
//	float result = max(max(a, -b), (a + r - b)*sqrt(0.5));

//	result = max(-box(p+mouse,float3(5,1,1)), result);

//	if(result > sphere(p,2.2)) result = max( -fractalType.FastWorley(p+mouse, freq, pers, lacun, 1), result);

//	result = max( -fractalType.FastWorley(p+mouse, freq, pers, lacun, 1), result);
	
//	result = max( fractalType.Simplex(p+mouse, freq, pers, lacun, 1)*.1, result);

//	result = max(sphere(p1,2)*.1,result);
//	result = smin ( ( max( (volume(p)*1) ,result)), ( max( (volume(p)*0.1) ,result)) ,.1);
//	result = smin ( ( max( (volume(p*.99)*.1) ,result)), ( max( (volume(p)*.1) ,result)) ,.1);
	
//	result = max( (volume(p)*0.1) ,sphere(p,2));
	
//	result = smin( box(p+2,1), box(p,2), .2);
//	result = box(p,2);
	
	return sphere(p,2) + saturate(fractalType.FastWorley(p, freq, pers, lacun, 1));
//	return sphere(p1,2);
//	return result * saturate(fractalType.Worley(Euclidean, F1, p, freq, pers, lacun, 1));
	
//	float vol =  max( (volume(p+float3(hash1(p.x)*ctrl2.x,hash1(p.y)*ctrl2.x,hash1(p.z)*ctrl2.x)))*.1 ,sphere(p,1));
//	float vol =  max( (volume(p))*.1 ,sphere(p,1));
//	return smin(vol,max(sphere(p,1),sphereRepeat(p*ctrl2.z,ctrl2.x)*.1),ctrl2.y);
//	return vol;
//	return volume(p)*.1;
//	return model(p);
//	return smin(max(sphereRepeat(p*ctrl2.z,ctrl2.x)*.1,box(p,1)),sphere(p,1),.3);
	
}


static const float PI = 3.1415926535897932384626433832795;
static const float PHI = 1.6180339887498948482045868343656;

float3 forwardSF( float i, float n) 
{
    float phi = 2.0*PI*frac(i/PHI);
    float zi = 1.0 - (2.0*i+1.0)/n;
    float sinTheta = sqrt( 1.0 - zi*zi);
    return float3( cos(phi)*sinTheta, sin(phi)*sinTheta, zi);
}

float calcAO( in float3 pos, in float3 nor)
{
	float ao = 0.0;
    for( int i=0; i<64; i++ )
    {
        float3 ap = forwardSF( float(i), 64.0 );
		ap *= sign( dot(ap,nor) ) * hash1(float(i));
		ao += clamp( sceneSDF( pos + nor*.1 + ap*.2 )*64.0, 0.0, 1.0 );
    }
	ao /= 64.0;
	
    return clamp( ao*ao, 0.0, 1.0 );
}
float3 calcNormal( in float3 pos )
{
	float3 eps = float3( 0.001, 0.0, 0.0 );
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
	for (uint i = 0 ; i < 1024 ; i++)
	{	
		
		if(dist < EPSILON || dist > MAX_DIST) break;
		
		dist = sceneSDF (eye + dir*t);
		t += dist * 0.5;
	}
	

//	if( t>MAX_DIST ) t=-1.0;
	return t;

}

float4 PS(VS_OUT input): SV_Target
{	
	
	float4 col;
	
//	float3 p;
	// Ray Origin
	float3 eye = tVI[3].xyz;

	// Ray Direction
	float3 dir = UVtoEYE(input.uv.xy);
	
	float edge = 0;
//	float dist = raymarchEdge(eye,dir,edge);
	float dist = raymarch(eye,dir);
	
	float3 p = eye + dist * dir;
 	float3 normal = calcNormal(p);
	
	
	float fog = max(1 - 5/(dist*dist*1),.0);
	float occ = 1;
//	occ = calcAO( p, normal);
//	occ = occ*occ;

//	float not_grid = box(p);
//	if(not_grid > .01)
//	{
//		col.rgb *= saturate(abs(frac(not_grid*10)*2-1)*10);
//	}
	
	
	
	// FRESNEL CALCS 
	float KrMin = 0;
	float Kr =1;
	float FresExp = 2;
	float3 reflVect = reflect(dir,normal);
	float vdn = -saturate(dot(reflVect,normal));
	float fresRefl = KrMin + (Kr-KrMin) * pow(1-abs(vdn),FresExp);	
	
	//	 Avoid artifacts for infinite distances
	if(abs(sceneSDF(p)) > .01){
		col = float4(.8,.8,1,0);
	}else{
		col = lerp((float4(.5,.5,.5,0)+fresRefl*float4(.6,.6,1,0))*occ,float4(.8,.8,1,0),fog);
//		col = lerp((float4(.5,.5,.5,0))*occ,float4(.8,.8,1,0),fog);
	} 
//	if(abs(sceneSDF(p)) > .1) col.xyz = (1 - fog)*p;

//	col += fractalType.Worley(cellDistance, cellFunction, p, freq, pers, lacun, oct);

    return saturate(col);
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}