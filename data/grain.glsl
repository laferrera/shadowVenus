#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform float time;
uniform float strength; // 16.0
uniform vec2 resolution;
varying vec4 vertTexCoord;
uniform sampler2D texture;

void main(void) {	
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	// vec4 color=texture2D(texture,vertTexCoord.st).rgba;
	vec4 color=texture2D(texture,uv).rgba;
	// float strength = 16.0;
	float x = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (time * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;	
	gl_FragColor = color + grain;
	
	// grain = 1.0 - grain;
	// gl_FragColor = color * grain;  
}

