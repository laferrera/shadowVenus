#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

const vec4 kRGBToYPrime=vec4(.299,.587,.114,0.);
const vec4 kRGBToI=vec4(.596,-.275,-.321,0.);
const vec4 kRGBToQ=vec4(.212,-.523,.311,0.);

const vec4 kYIQToR=vec4(1.,.956,.621,0.);
const vec4 kYIQToG=vec4(1.,-.272,-.647,0.);
const vec4 kYIQToB=vec4(1.,-1.107,1.704,0.);

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float hue;

void main()
{
    // Sample the input pixel
    vec4 color=texture2D(texture,vertTexCoord.st).rgba;
    
    // Convert to YIQ
    float YPrime=dot(color,kRGBToYPrime);
    float I=dot(color,kRGBToI);
    float Q=dot(color,kRGBToQ);
    
    // Calculate the chroma
    float chroma=sqrt(I*I+Q*Q);
    
    // Convert desired hue back to YIQ
    Q=chroma*sin(hue);
    I=chroma*cos(hue);
    
    // Convert back to RGB
    vec4 yIQ=vec4(YPrime,I,Q,0.);
    color.r=dot(yIQ,kYIQToR);
    color.g=dot(yIQ,kYIQToG);
    color.b=dot(yIQ,kYIQToB);
    
    // Save the result
    gl_FragColor=color;
}