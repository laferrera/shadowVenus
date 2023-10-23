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
const float strength=1.;
const int samples=64;//multiple of 2
const float threshold=.3;// Color key threshold (0-1) // 0.6
const float brightness=6.;// Glow brightness 5.0


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

void main()
{

    
    vec2 uv=(gl_FragCoord.xy/resolution.xy);//*vec2(1.,-1.);
    vec2 dir=(gl_FragCoord.xy-vec2(float(resolution.x)/2.,float(resolution.y)/2.))/resolution.xy*vec2(-.5,-.5);

    vec4 color=vec4(0.,0.,0.,1.);

    float falloffMod = float(samples) * (.1*sin(1.81*time));

    float rnd=random(uv);
    // rnd = .1*cheapFBM(rnd + uv.x + uv.y);
    rnd=cheapFBM(rnd+uv.x+uv.y);
        // +.5*sin(time*93.3*(uv.x+rnd))
        // +.5*cos(time*71.6*(uv.y+rnd));    

    float samplesSize = float(samples) + falloffMod;
    for(int i=0;i<samplesSize;i+=2){//operating at 2 samples for better performance        
        // float falloff=1.-abs(i/samples-rnd);
        // float falloff=1.-abs(i/samplesSize);
        falloffMod = .3*rnd + 1.+falloffMod / samplesSize;
        color+=texture2D(texture,uv+float(i)/samplesSize*dir*strength*falloffMod);
        color+=texture2D(texture,uv+float(i+1)/samplesSize*dir*strength*falloffMod);        
        // color+=texture2D(texture,uv+float(i)/float(samples)*dir*strength*falloffMod);
        // color+=texture2D(texture,uv+float(i+1)/float(samples)*dir*strength*falloffMod);                

        if(color.r+color.g+color.b>threshold*3.){
            gl_FragColor+=color*brightness*falloffMod;
        }

    }

    gl_FragColor=color/float(samples);
    gl_FragColor += texture2D(texture,uv);
}