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

float3 mouse;


SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

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
	return (length(p) - 1 )*.1;
}

float time;

// Distance field function
float sceneSDF (float3 p)
{
	float3 p1 = p;
//	return lerp(box(p),sphere(p),.5);

//	return smin(box(p),sphere(p),.2);

//	return max(box(p),sphere(p));

		//Domain Distortion
		p1.xyz += 1.000*sin(  2.0*p1.yzx +time)*1.5;
	    p1.xyz += 0.500*sin(  4.0*p1.yzx -time*15.1)*1.5;
	    p1.xyz += 0.250*sin(  8.0*p1.yzx +time*10.2)*1.5;
	    p1.xyz += 0.050*sin( 16.0*p1.yzx -time*14.3)*1.5;
	//	return sphere(p1);
//	
//		// Combine
		return smin(sphere(p+mouse*.75),sphere(p1),.3);
	
//	return smin(sphere(p), sphere(p + float3(2,0,0)),.03);

}

float hash1( float n )
{
    return frac(sin(n)*43758.5453123);
}
float hashTime;
float hash1( in float2 f ) 
{ 
    return frac(sin(f.x+131.1*f.y)*43758.5453123+ hashTime.x) ; 
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
//        ao += clamp( sceneSDF( pos + nor*.3 + ap*.5 )*16.0, 0.0, 1.0 );
		  ao += clamp( sceneSDF( pos + nor*.1 + ap*.3 )*64.0, 0.0, 1.0 );
    }
	ao /= 64.0;
	
    return clamp( ao*ao, 0.0, 1.0 );
//	return 1;
}
float3 calcNormal( in float3 pos )
{
	float3 eps = float3( 0.0001, 0.0, 0.0 );
	float3 nor = float3(
	sceneSDF(pos+eps.xyy) - sceneSDF(pos-eps.xyy),
	sceneSDF(pos+eps.yxy) - sceneSDF(pos-eps.yxy),
	sceneSDF(pos+eps.yyx) - sceneSDF(pos-eps.yyx) );
	return normalize(nor);
}

static const float MAX_DIST = 5.0;
static const float EPSILON = .00001;


float raymarch (in float3 eye, in float3 dir)
{
	float t = 0.0;
	float	dist = .01;
	for (uint i = 0 ; i < 2048 ; i++)
	{	
		
		if(dist < EPSILON || dist > MAX_DIST) break;
		
		dist = sceneSDF (eye + dir*t);
		t += dist * 0.5;
	}
	
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

	float dist = raymarch(eye,dir);
	
	float3 p = eye + dist * dir;

 	float3 normal = calcNormal(p);
	
	
	float fog = max(1 - 1/(1+dist*dist*.15),.0);
	float occ = 1;
	occ = calcAO( p, normal);
	
	// FRESNEL CALCS 
	float KrMin = 0;
	float Kr =1;
	float FresExp = 2;
	float3 reflVect = reflect(dir,normal);
	float vdn = -saturate(dot(reflVect,normal));
	float fresRefl = KrMin + (Kr-KrMin) * pow(1-abs(vdn),FresExp);	
	
	col = lerp((float4(.5,.5,.5,0)+fresRefl*float4(.5,.5,1,0))*occ,float4(.8,.8,1,0),fog);

    return saturate(col);
}


float3 ortho(float3 d) {
	if (abs(d.x)>0.00001 || abs(d.y)>0.00001) {
		return float3(d.y,-d.x,0.0);
	} else  {
		return float3(0.0,d.z,-d.y);
	}
}



static const float subframe = 1;


float2 rand2(float2 uv){// implementation dierived from one found at: lumina.sourceforge.net/Tutorials/Noise.html
	float2 randv2=frac(cos((uv.xy+uv.yx*float2(1000.0,1000.0))+float2(hashTime,hashTime))*10000.0);
	
	randv2+=float2(1.0,1.0);
	return float2(frac(sin(dot(randv2.xy ,float2(12.9898,78.233))) * 43758.5453),
		frac(cos(dot(randv2.xy ,float2(4.898,7.23))) * 23421.631));
}


float3 getSampleBiased(float3  dir, float power, float2 viewCoord, uint i) {
	dir = normalize(dir);
	// create orthogonal vector
	float3 o1 = normalize(ortho(dir));
	float3 o2 = normalize(cross(dir, o1));
	
	// Convert to spherical coords aligned to dir;
//	float2 r = float2(hash1(viewCoord+i),
//					  hash1(viewCoord+.03+i) );
	float2 r = rand2(viewCoord);
	r.x=r.x*2.*PI;
	
	// This is  cosine^n weighted.
	// See, e.g. http://people.cs.kuleuven.be/~philip.dutre/GI/TotalCompendium.pdf
	// Item 36
	r.y=pow(r.y,1.0/(power+1.0));
	
	float oneminus = sqrt(1.0-r.y*r.y);
	float3 sdir = cos(r.x)*oneminus*o1+
	sin(r.x)*oneminus*o2+
	r.y*dir;
	
	return sdir;
}

float3 getSample(float3 dir, float extent, float2 viewCoord, uint i) {
	// Create orthogonal vector (fails for z,y = 0)
	dir = normalize(dir);
	float3 o1 = normalize(ortho(dir));
	float3 o2 = normalize(cross(dir, o1));
	
	// Convert to spherical coords aligned to dir
	float2 r =  hash1(viewCoord*(float(subframe)+1.0) + i);
	
//	if (Stratify) {r*=0.1; r+= cx;}
	r.x=r.x*2.*PI;
	//	r.y=1.0-r.y*extent;
	
	float oneminus = sqrt(1.0-r.y*r.y);
	return cos(r.x)*oneminus*o1+sin(r.x)*oneminus*o2+r.y*dir;
}

TextureCube environment;
float4 getBackground(float3 dir) {
	
	return max(environment.SampleLevel(linearSampler,dir,0)*3, float4(0,0,.0,0) );
	
//	return float4(1,1,1,0);

}


float3 getConeSample(float3 dir, float extent, float2 uv) {
        // Formula 34 in GI Compendium
	dir = normalize(dir);
	float3 o1 = normalize(ortho(dir));
	float3 o2 = normalize(cross(dir, o1));
	float2 r =  rand2(uv);
	r.x=r.x*2.*PI;
	r.y=1.0-r.y*extent;
	float oneminus = sqrt(1.0-r.y*r.y);
	return cos(r.x)*oneminus*o1+sin(r.x)*oneminus*o2+r.y*dir;
}

static const uint RayDepth = 64;
static const uint minDist = 1;
float3 PS_path(VS_OUT input): SV_Target
{	
	
	float4 col;
	
//	float3 p;
	// Ray Origin
	float3 eye = tVI[3].xyz;

	// Ray Direction
	float3 dir = UVtoEYE(input.uv.xy);
	

	  float3 hit = (float3)(0.0);
	  float3 hitNormal = (float3)(0.0);
	  float3 direct = (float3)(0.0);
		
	  float3 luminance = (float3)(1.0);
	  for (uint i=0; i < RayDepth; i++) {
	  	float dist = raymarch(eye,dir);
	    if ((dist) < MAX_DIST * 2) {
	    	
	    	hit = eye + dist * dir;
	    	hitNormal = calcNormal(hit);
	        dir = getSampleBiased(hitNormal,5,input.uv.xy,i); // new direction (towards light)
		    luminance *= 1* dot(dir,hitNormal);
	        eye = hit + hitNormal*minDist*1.0; // new start point
	    	
	    	// Direct lighting
//		       float3 sunSampleDir = getConeSample(float3(0,1,0),1,input.uv.xy);
//		       float sunLight = dot(hitNormal, sunSampleDir);
//		    	
//		       if (sunLight>0.0 && raymarch(eye + hitNormal*1.0*minDist,sunSampleDir) > MAX_DIST * 2)
//		    	{
//		    		// 1E-5
//		        direct += luminance * sunLight * 1;
//		       }
	     	

	    } else {
	      return luminance * getBackground( dir );
	
	    }
	  }
	
	  return (float3)(0.0); // Ray never reached a light source

}




technique10 Raymarch
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}


technique10 Pathtracer
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_path() ) );
	}
}




