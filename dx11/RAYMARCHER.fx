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

float3 UVtoEYE(float2 UV){
	return normalize( mul(float4(mul(float4((UV.xy*2-1)*float2(1,-1),0,1),tPI).xy,1,0),tVI).xyz);
}

// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

float box (float3 p){
//	p = 1 - frac(p)*2;
	p = abs(p) - float3(.25,.25,.25);
	return max(p.x,max(p.y,p.z));
}

float plane (float3 p){
	return (p.y);
}

float sphere (float3 p){
//	p = 1 - frac(p)*2;
//	p+=mouse;
	return (length(p+mouse) - .5 ) +  (sin(20*p.x)*sin(20*p.y)*sin(20*p.z))*.1;
}

float opRep( float3 p, float3 c )
{
    float3 q = fmod(p,c)*c;
    return lerp(box(q),plane(q)+.5,.1);
}

// Distance field function
float map (float3 p)
{
//	return lerp(box(p),sphere(p),.5);
//	return smin(box(p),sphere(p),.2);
	return max(box(p),-sphere(p));
//	return opRep(p,1);
}
float3 calcNormal( in float3 pos )
{
	float3 eps = float3( 0.0001, 0.0, 0.0 );
	float3 nor = float3(
	    map(pos+eps.xyy) - map(pos-eps.xyy),
	    map(pos+eps.yxy) - map(pos-eps.yxy),
	    map(pos+eps.yyx) - map(pos-eps.yyx) );
	return normalize(nor);
}
float raymarch (in float3 ro, in float3 rd, inout float3 p)
{
	float t = 0.0;
	for (int i = 0 ; i < 64 ; i++)
	{
		p = ro + rd*t;
		float d = map (p);
		t += d * 0.5;
	}
	return t;
}


float4 PS(VS_OUT input): SV_Target
{	
	
	float4 col;
	
	float3 p;
	// Ray Origin
	float3 ro = tVI[3].xyz;

	// Ray Direction
	float3 rd = UVtoEYE(input.uv.xy);

	float d = raymarch(ro,rd,p);
	
//	float3 normal = 1;
 	float3 normal = calcNormal(p);

	
	float fog = 1 - 1/(1+d*d*.15);
//	col = float4(length(p)*fog + (1 - fog)*p,1); 
//	float4 col = float4(p*fog + (1 - fog),1); 


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
	float FresExp = 3;
	float3 reflVect = reflect(rd,normal);
	float vdn = -saturate(dot(reflVect,normal));
	float fresRefl = KrMin + (Kr-KrMin) * pow(1-abs(vdn),FresExp);	
	
	
//	col = lerp(float4(.5,.5,.5,0)+float4(min(normal,0),1)+fresRefl*float4(1,0,0,0),float4(.5,0,1,0),fog);
	col = lerp(float4(.9,.9,.9,0)+fresRefl*float4(1,1,1,0),float4(.5,0,1,0),fog);
//	col = float4(1,1,1,0)+float4(min(normal,0)+fresRefl*.1,1);
	
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




