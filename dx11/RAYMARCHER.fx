//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 


	float4x4 tVP : LAYERVIEWPROJECTION;	
	float4x4 tVI: VIEWINVERSE;
	float4x4 tW : WORLD;
	float4x4 tPI : PROJECTIONINVERSE;

StructuredBuffer <float3> particles;

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

float sphere (float3 p){

	//Repeat
//	p = 1 - frac(p)*2;

	// Displaced Sphere + Mouse
//	p+=mouse;
//	return (length(p+mouse) - .5 ) +  (sin(10*p.x)*sin(10*p.y)*sin(10*p.z))*.1;

	// Simple Sphere
	return (length(p) - 1.5 )*.1;
}

float time;

float particleCloud(float3 p){
	
	uint x,m;
	particles.GetDimensions(x,m);
	float cloud = sphere(particles[0]+p);
	for(uint i=1; i < x; i++){
		cloud = min( (sphere(particles[i]+p)), cloud) ;
	}
	return cloud;
}

// Distance field function
float sceneSDF (float3 p)
{
	float3 p1 = p;
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
//	float a = sphere(p+mouse);
//	float b = sphere(p1);
//	float r = .1;
//	return max(max(a, -b), (a + r - b)*sqrt(0.5));
	
	// Combine
//	return smin(sphere(p+mouse),sphere(p1),.2);

	//Pipe
//	float a = box(p,float3(1.0,1.2,1.0));
//	float b = box(p,float3(1,1,1));
//	float r = .1;
//	return length(float2(a, b)) - r;

//	return min(min(min(sphere(p+mouse), sphere(p)), sphere(p+float3(.1,1,1))),sphere(p+float3(.1,3,1)));
	return particleCloud(p);
}

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
		ao += clamp( sceneSDF( pos + nor*.1 + ap*.3 )*64.0, 0.0, 1.0 );
    }
	ao /= 64.0;
	
    return clamp( ao*ao, 0.0, 1.0 );
//	return 1;
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
	
	
	float fog = max(1 - 1/(1+dist*dist*.15),.0);
	float occ = 1;
	occ = calcAO( p, normal);
//	occ = occ*occ;

//	float not_grid = box(p);
//	if(not_grid > .01)
//	{
//		col.rgb *= saturate(abs(frac(not_grid*10)*2-1)*10);
//	}
	
	// Avoid artifacts for infinite distances
//	if(abs(map(p)) > .1) discard;
//	if(abs(map(p)) > .1) col.xyz = (1 - fog)*p;

	
	// FRESNEL CALCS 
	float KrMin = 0;
	float Kr =1;
	float FresExp = 2;
	float3 reflVect = reflect(dir,normal);
	float vdn = -saturate(dot(reflVect,normal));
	float fresRefl = KrMin + (Kr-KrMin) * pow(1-abs(vdn),FresExp);	
	
	
//	col = lerp(float4(.5,.5,.5,0)+float4(min(normal,0),1)+fresRefl*float4(1,0,0,0),float4(.5,0,1,0),fog);
	col = lerp((float4(.5,.5,.5,0)+fresRefl*float4(.5,.5,1,0))*occ,float4(.8,.8,1,0),fog);

//	col = fog;
	
//	return  lerp(float4(1,1,1,1),float4(0,0,0,1),edge);

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




