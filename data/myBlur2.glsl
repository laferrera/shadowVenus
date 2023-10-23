#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture;
uniform int blurSize;       
// uniform float sigma;

float  normpdf(in float  x,  in float  sigma)  {
    return  0.39894 * exp(-0.5 * x * x / (sigma * sigma)) / sigma;
}

//Screen function
vec3 screen(vec3 base,vec3 bl_layer){
    return base+bl_layer-base*bl_layer;
}

//Opacity function
vec4 opacity(float alpha, vec4 texColor,vec4 blendResult){
    return((1.-alpha)*texColor+alpha*blendResult);
}

void main() {
    
	// vec2  uv = fragCoord / iResolution.xy;
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    vec3  c = texture2D(texture,uv).rgb;
    
    vec2  center = vec2(0.5, 0.5);

    float  d = smoothstep(0.3, 1.0, 0.1 + distance(center, uv));

    //  grain  effect
    float  strength = 4.0; // was 4.0
    float  x = (uv.x + 4.0) * (uv.y + 4.0) * (time * 10.0);
    vec3  grain = vec3(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01) - 0.005) * strength;

    // blur stuff i think?
    const int  mSize = 11;
    const int  kSize = (mSize - 1) / 2;
    float  kernel[mSize];
    vec3  final_colour = vec3(0.0);

    //create  the  1-D  kernel
    float  sigma = 0.001 + texture2D(texture, uv).w * 1.5;//7.0; or 4.0
    float  Z = 0.0;
    for (int  j = 0; j <= kSize; ++j) {
        kernel[kSize + j] = kernel[kSize - j] = normpdf(float(j), sigma);
    }

    //get  the  normalization  factor  (as  the  gaussian  has  been  clamped)
    for (int  j = 0; j < mSize; ++j) {
        Z += kernel[j];
    }

    //read  out  the  texels
    for (int  i = -kSize; i <= kSize; ++i) {
        for(int  j = -kSize; j <= kSize; ++j) {
            final_colour += kernel[kSize + j] * kernel[kSize + i] * texture2D(texture, (gl_FragCoord.xy + vec2(float(i), float(j))) / resolution.xy).rgb;
                }
    }

    vec3  c_step_1 = final_colour / (Z * Z);

    float  nd = 1.0 - d;
    vec3 c_step_2 = clamp(c_step_1 * nd, 0.0, 1.0);

    // I don't like the image too clean
    c_step_2 += grain * 3.0; // was 3.0

    // just straight blur
    // gl_FragColor = vec4(c_step_2, 1.0);

    
    // screen it over the original
    vec4 layer=vec4(c_step_2,1.0);
    vec4 screenResult=vec4(screen(c.rgb,layer.rgb),1.);
    // gl_FragColor = screenResult;
    float alpha=.5;
    gl_FragColor=opacity(alpha,vec4(c,1.0),layer);



}