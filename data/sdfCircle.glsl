// https://www.shadertoy.com/view/lsSXR3

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform vec2 resolution;
uniform sampler2D texture;
uniform float time;


uniform float radius;
uniform vec3 color1;
uniform vec3 color2;


float sdCircle( in vec2 p, in float r ) 
{
    return length(p)-r;
}


void main()
{
    // gl_FragCoord
	vec2 p = (2.0*gl_FragCoord.xy-resolution.xy)/resolution.y;
    // vec2 m = (2.0*iMouse.xy-resolution.xy)/resolution.y;
    
    // float d = sdCircle(p,0.5);

    float t = time*0.5;
    // float r = 0.5+0.5*sin(t);
	// float d = sdCircle(p,r);
    float d = sdCircle(p,radius);
    
	// old coloring
    // vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
    // new coloring
    vec3 col = (d>0.0) ? color1 : color2;



    col *= 1.0 - exp(-6.0*abs(d));
	col *= 0.8 + 0.2*cos(150.0*d);
	col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.01,abs(d)) );

	gl_FragColor = vec4(col,1.0);
}