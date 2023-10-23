#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
const vec4  kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
const vec4  kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);

const vec4  kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
const vec4  kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
const vec4  kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float hue = .5;
const float brightness=.0;
const float contrast=1.0;
const float saturation=.5;

mat4 brightnessMatrix(float brightness)
{
    return mat4(1,0,0,0,
        0,1,0,0,
        0,0,1,0,
    brightness,brightness,brightness,1);
}

mat4 contrastMatrix(float contrast)
{
    float t=(1.-contrast)/2.;
    
    return mat4(contrast,0,0,0,
        0,contrast,0,0,
        0,0,contrast,0,
    t,t,t,1);
    
}

mat4 saturationMatrix(float saturation)
{
    vec3 luminance=vec3(.3086,.6094,.0820);
    
    float oneMinusSat=1.-saturation;
    
    vec3 red=vec3(luminance.x*oneMinusSat);
    red+=vec3(saturation,0,0);
    
    vec3 green=vec3(luminance.y*oneMinusSat);
    green+=vec3(0,saturation,0);
    
    vec3 blue=vec3(luminance.z*oneMinusSat);
    blue+=vec3(0,0,saturation);
    
    return mat4(red,0,
        green,0,
        blue,0,
    0,0,0,1);
}


void main ()
{
    // Sample the input pixel
	vec4 color = texture2D(texture, vertTexCoord.st).rgba;
    vec4 tex=texture2D(texture,vertTexCoord.st).rgba;
    // Convert to YIQ
    // float   YPrime  = dot (color, kRGBToYPrime);
    // float   I      = dot (color, kRGBToI);
    // float   Q      = dot (color, kRGBToQ);

    // // Calculate the chroma
    // float   chroma  = sqrt (I * I + Q * Q);

    // // Convert desired hue back to YIQ
    // Q = chroma * sin (hue);
    // I = chroma * cos (hue);

    // // Convert back to RGB
    // vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
    // color.r = dot (yIQ, kYIQToR);
    // color.g = dot (yIQ, kYIQToG);
    // color.b = dot (yIQ, kYIQToB);

    // just hue...
    // gl_FragColor=color;

    gl_FragColor=brightnessMatrix(brightness)*
    contrastMatrix(contrast)*
    saturationMatrix(saturation)*
    color;

}