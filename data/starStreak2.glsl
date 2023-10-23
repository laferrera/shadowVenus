// streaks
// https://www.shadertoy.com/view/NlyfDW


// glow
// https://www.shadertoy.com/view/NlyfDW

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
varying vec4 vertTexCoord;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture;
uniform float range=.2;// Length of glow streaks // 0.1
uniform float steps=.01;// Number of texture samples divided by 2   // 0.005
uniform float threshold=.3;// Color key threshold (0-1) // 0.6
uniform float brightness=5.;// Glow brightness 5.0


float random(vec2 st){
    return fract(sin(dot(st.xy*time,
                vec2(12.9898,78.233)))*
            43758.5453123);
}

float cheapFBM(float x){
    float amplitude=1.;
    float frequency=1.;
    float y=sin(x*frequency);
    float t=.01*(-time*130.);
    y+=sin(x*frequency*2.1+t)*4.5;
    y+=sin(x*frequency*1.72+t*1.121)*4.;
    y+=sin(x*frequency*2.221+t*.437)*5.;
    y+=sin(x*frequency*3.1122+t*4.269)*2.5;
    y*=amplitude*.06;
    return y;
}

void main() {

    // vec2 uv = fragCoord / iResolution.xy;
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    gl_FragColor = texture2D(texture, uv);    

    float diagFalloffMod=.1*abs(0.1*sin(1.81*time));
    float axisFalloffMod=.05*abs(0.1*sin(.73*time));
    // float diagFalloffMod=0.0;
    // float axisFalloffMod=0.0;


    float moddedRange = range + diagFalloffMod;

    float rnd=random(uv);
    // rnd = .1*cheapFBM(rnd + uv.x + uv.y);
    rnd = .05 * cheapFBM(rnd + uv.x + uv.y)
            + 0.08*sin(time*93.3*(uv.x+rnd)) 
            + 0.08*cos(time*71.6*(uv.y+rnd));
        // rnd *=.1;
        // float rnd=.1 * cheapFBM(uv.x+uv.y) + 0.001 *random(uv);
    for (float i = -moddedRange; i < moddedRange; i += steps) {
        
        float diagFalloff=1.-abs(i/(moddedRange-rnd));
        float axisFalloff=1.-abs(i/(axisFalloffMod-rnd+range));
    
        vec4 blur = texture2D(texture, uv + i);
        if (blur.r + blur.g + blur.b > threshold * 3.0) {
            gl_FragColor += blur * diagFalloff * steps * brightness;
        }
        
        blur = texture2D(texture, uv + vec2(i, -i));
        if (blur.r + blur.g + blur.b > threshold * 3.0) {
            gl_FragColor += blur * diagFalloff * steps * brightness;
        }

        blur=texture2D(texture,uv+vec2(i,0));
        if(blur.r+blur.g+blur.b>threshold*3.){
            gl_FragColor+=blur*axisFalloff*steps*brightness;
        }

        blur=texture2D(texture,uv+vec2(0,-i));
        if(blur.r+blur.g+blur.b>threshold*3.){
            gl_FragColor+=blur*axisFalloff*steps*brightness;
        }
    }
}