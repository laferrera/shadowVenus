#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2 _iResolution;
uniform vec2 resolution;
uniform sampler2D _Tex;
uniform sampler2D texture;
uniform float _Decay;
void main() {
    // vec2 uv = gl_FragCoord.xy/_iResolution;
    vec2 uv=gl_FragCoord.xy/resolution;
    uv.y = 1. - uv.y;
    // vec2 pixelsize = 1.0/_iResolution;
    vec2 pixelsize=1./resolution;

    float gray = (texture2D(_Tex, uv).x*3.0+
                texture2D(_Tex, uv + pixelsize).x+
                texture2D(_Tex, uv + vec2(pixelsize.x, -pixelsize.y)).x+
                texture2D(_Tex, uv + vec2(pixelsize.x, 0)).x+
                texture2D(_Tex, uv + vec2(0, pixelsize.y)).x+
                texture2D(_Tex, uv - pixelsize).x+
                texture2D(_Tex, uv - vec2(pixelsize.x, -pixelsize.y)).x+
                texture2D(_Tex, uv - vec2(pixelsize.x, 0)).x+
                texture2D(_Tex, uv - vec2(0, pixelsize.y)).x)/11.0;
    gl_FragColor = vec4(vec3(gray-_Decay), 1);
}