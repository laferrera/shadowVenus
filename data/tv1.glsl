// https://www.shadertoy.com/view/XtcSRs
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
varying vec4 vertTexCoord;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture;

// Creates a "/\" curve between [0.0,1.0]
float SpikeMap( float t )
{
    return 1.0 - abs(2.0 * t - 1.0);
}

// Remaps T into the domain [a,b] and returns [0.0,1.0]
// Depending on where it lands within this range
float Remap( float t, float a, float b )
{
    return clamp( (t-a) / (b-a) , 0.0, 1.0 );
}

// Makes a gradient of [ R | G | B ] mapped to [0.0,1.0]
// Used to map RGB contribution 
vec4 RGBGradient( float t )
{
    float Low = step(t,0.5);
    float High = 1.0 - Low;
    float w = SpikeMap(Remap( t, 1.0/6.0, 5.0/6.0 ));
	return vec4( Low, 1.0, High, 1.0) * vec4(1.0-w, w, 1.0-w, 1.0);
}

// Just a basic vignetting
vec2 LensBuldge( vec2 Coord, vec2 Center, float Amount )
{
    vec2 CenterOff = Coord - Center;
    float Distance = dot(CenterOff,CenterOff);
    return CenterOff * Distance * Amount;
}

float BayerIndex( uvec2 FragPos )
{
    const uint indexMatrix4x4[16] = uint[](
         0u,  8u,  2u, 10u,
        12u,  4u, 14u,  6u,
         3u, 11u,  1u,  9u,
        15u,  7u, 13u,  5u
    );

    uvec2 MatrixPos = FragPos & uvec2(3, 3); // % 4
    return float(indexMatrix4x4[MatrixPos.x | (MatrixPos.y << 2)]) / 15.0;
}

const uint Iter = 9u;
const float IterStep = 1.0 / float(Iter);

void main()
{
	vec2 UV = gl_FragCoord.xy / resolution.xy;
    // vec2 Focus = iMouse.z > 0.0 ? (iMouse.xy / resolution.xy) : vec2(0.5, 0.5);    
    vec2 Focus=vec2(.5,.5);
    
    float Bayer = BayerIndex(uvec2(gl_FragCoord));
    
    vec4 AccumColor = vec4(0.0);
    vec4 AccumSpectral = vec4(0.0);
    
    for( uint i = 0u; i < Iter; ++i )
    {
        float Phase = (float(i) / (float(Iter - 1u)))
                    + mix(-IterStep, IterStep, Bayer) * 0.25;                

        vec4 SpectrumContrib = RGBGradient( Phase );
        AccumSpectral += SpectrumContrib;
        vec2 FringeUV = LensBuldge( UV, Focus, Phase );
        AccumColor += SpectrumContrib * texture2D(texture, UV + FringeUV ); 
    }
    
	gl_FragColor = AccumColor / AccumSpectral;
}