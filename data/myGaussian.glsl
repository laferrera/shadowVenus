// https://www.shadertoy.com/view/XdfGDH

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform vec2 resolution;
uniform sampler2D texture;

float normpdf(in float x,in float sigma)
{
    return .39894*exp(-.5*x*x/(sigma*sigma))/sigma;
}

//Screen function
vec3 screen(vec3 base,vec3 bl_layer){
    return base+bl_layer-base*bl_layer;
}

//Opacity function
vec4 opacity(float alpha,vec4 texColor,vec4 blendResult){
    return((1.-alpha)*texColor+alpha*blendResult);
}

void main()
{
    vec2 uv=gl_FragCoord.st/resolution.xy;
    vec4 texColor=texture2D(texture,uv);
    vec3 c=texColor.rgb;
    
    //declare stuff
    const int mSize=11;
    const int kSize=(mSize-1)/2;
    float kernel[mSize];
    vec3 final_colour=vec3(0.);
    
    //create the 1-D kernel
    float sigma=7.;// was 7.0
    float Z=0.;
    for(int j=0;j<=kSize;++j)
    {
        kernel[kSize+j]=kernel[kSize-j]=normpdf(float(j),sigma);
    }
    
    //get the normalization factor (as the gaussian has been clamped)
    for(int j=0;j<mSize;++j)
    {
        Z+=kernel[j];
    }
    
    //read out the texels
    for(int i=-kSize;i<=kSize;++i)
    {
        for(int j=-kSize;j<=kSize;++j)
        {
            final_colour+=kernel[kSize+j]*kernel[kSize+i]*texture2D(texture,(gl_FragCoord.st+vec2(float(i),float(j)))/resolution.xy).rgb;
            
        }
    }
    
    // gl_FragColor = vec4(final_colour/(Z*Z), 1.0);
    
    vec4 layer=vec4(final_colour/(Z*Z),1.);
    
    //Change Blendmode here<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    vec4 blendResult=vec4(screen(texColor.rgb,layer.rgb),1.);
    
    // Change to 0.0 - 1.0 to set opacity of a blending layer<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    float alpha=.25;
    
    // gl_FragColor=opacity(alpha,texColor,blendResult);
    gl_FragColor=opacity(alpha,texColor,layer);
    
}