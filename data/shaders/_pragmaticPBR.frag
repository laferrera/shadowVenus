#ifdef VERT

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 modelWorldMatrix;
uniform mat4 viewMatrix;
uniform mat4 normalMatrix;
uniform float pointSize;
uniform vec3 lightPos;
uniform vec3 cameraPos;

attribute vec3 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec3 ecNormal;
varying vec3 ecLightPos;
varying vec3 ecPosition;
varying vec3 wcNormal;
varying vec3 wcCoords;

void main() {
  vec4 worldPos = modelWorldMatrix * vec4(position, 1.0);
  ecPosition = vec3(modelViewMatrix * vec4(position, 1.0));
  gl_Position = projectionMatrix * vec4(ecPosition, 1.0);

  ecNormal = (normalMatrix * vec4(normal, 0.0)).xyz;
  ecLightPos = (viewMatrix * vec4(lightPos, 1.0)).xyz;

  wcNormal = normal;
  wcCoords = (modelWorldMatrix * vec4(position, 1.0)).xyz;
}

#endif

#ifdef FRAG

#extension GL_EXT_shader_texture_lod : require
/*
#ifdef WEBL
  #extension GL_EXT_shader_texture_lod : require
#else
  #extension GL_ARB_shader_texture_lod : require
#endif
*/

varying vec3      ecNormal;
varying vec3      ecLightPos;
varying vec3      ecPosition;
varying vec3      wcNormal;
varying vec3      wcCoords;
uniform bool      correctGamma;
uniform float     show;
uniform bool      skyBox;
uniform vec4      baseColor;
uniform sampler2D baseColorMap;
uniform bool      baseColorMapEnabled;
uniform vec4      specularColor;
uniform sampler2D specularMap;
uniform bool      specularMapEnabled;
uniform sampler2D glossMap;

uniform sampler2D normalMap;
uniform float     globalRoughness; //smooth/shiny <--> rough/matte
uniform float     globalSpecular;
uniform mat4      invViewMatrix;
uniform samplerCube reflectionMap;
uniform samplerCube diffuseMap;
uniform sampler2D ssaoMap;
uniform vec2 windowSize;
uniform bool custom;

const float PI = 3.14159265358979323846;

//-----------------------------------------------------------------------------

float material_cubemapSize = 128.0;
float material_cubemapSize2 = 32.0;

vec3 fixSeams(vec3 vec, float mipmapIndex, float size) {
    float scale = 1.0 - exp2(mipmapIndex) / size;
    float M = max(max(abs(vec.x), abs(vec.y)), abs(vec.z));
    if (abs(vec.x) != M) vec.x *= scale;
    if (abs(vec.y) != M) vec.y *= scale;
    if (abs(vec.z) != M) vec.z *= scale;
    return vec;
}

vec3 fixSeams(vec3 vec, float size ) {
    float scale = 1.0 - 1.0 / size;
    float M = max(max(abs(vec.x), abs(vec.y)), abs(vec.z));
    if (abs(vec.x) != M) vec.x *= scale;
    if (abs(vec.y) != M) vec.y *= scale;
    if (abs(vec.z) != M) vec.z *= scale;
    return vec;
}

//-----------------------------------------------------------------------------

vec4 sampleEnvMap(samplerCube envMap, vec3 ecN, vec3 ecPos, float mipmapIndex, float size) {
  vec3 eyeDir = normalize(-ecPos); //Direction to eye = camPos (0,0,0) - ecPos
  vec3 ecReflected = reflect(-eyeDir, ecN); //eye coordinates reflection vector

  float mipmap = mipmapIndex;

  if (skyBox) {
    ecReflected = normalize(ecPos);
    mipmap = 0.0;
    vec3 wcReflected = vec3(invViewMatrix * vec4(ecReflected, 0.0)); //world coordinates reflection vector
    return textureCubeLod(envMap, fixSeams(wcReflected, mipmap, size), mipmap);
  }

  vec3 wcReflected = vec3(invViewMatrix * vec4(ecReflected, 0.0)); //world coordinates reflection vector

  //return textureCubeLod(envMap, fixSeams(wcReflected, mipmap), mipmap);
  float lod = mipmap;
  float upLod = floor(lod);
  float downLod = ceil(lod);
  vec4 a = textureCubeLod(envMap, fixSeams(wcReflected, upLod, size), upLod);
  vec4 b = textureCubeLod(envMap, fixSeams(wcReflected, downLod, size), downLod + 0.1);
  return mix(a, b, lod - upLod);
}

//Convert color to linear space
//http://filmicgames.com/archives/299
//http://www.cambridgeincolour.com/tutorials/gamma-correction.htm
vec4 gammaToLinear(vec4 color) {
  if (correctGamma) {
    return vec4(pow(color.rgb, vec3(2.2)), color.a);
  }
  else {
    return color;
  }
}

vec4 linearToGamma(vec4 color) {
  if (correctGamma) {
    return vec4(pow(color.rgb, vec3(1.0 / 2.2)), color.a);
  }
  else {
    return color;
  }
}

float triPlanarScale = 0.5;

vec4 sampleTriPlanar(sampler2D tex, float scale) {
  vec3 blending = abs( normalize(wcNormal) );
  blending = normalize(max(blending, 0.00001)); // Force weights to sum to 1.0
  float b = (blending.x + blending.y + blending.z);
  blending /= vec3(b, b, b);

  vec4 xaxis = texture2D( tex, mod(wcCoords.zy * triPlanarScale, vec2(1.0, 1.0)));
  vec4 yaxis = texture2D( tex, mod(wcCoords.xz * triPlanarScale, vec2(1.0, 1.0)));
  vec4 zaxis = texture2D( tex, mod(wcCoords.xy * triPlanarScale, vec2(1.0, 1.0)));
  // blend the results of the 3 planar projections.
  vec4 color = xaxis * blending.x + yaxis * blending.y + zaxis * blending.z;

  return color;
}

vec4 sampleTriPlanar(sampler2D tex) {
  return sampleTriPlanar(tex, triPlanarScale);
}

//-----------------------------------------------------------------------------

vec3 triPlanarTangent() {
  vec3 blending = abs( normalize(wcNormal) );
  blending = normalize(max(blending, 0.00001)); // Force weights to sum to 1.0
  float b = (blending.x + blending.y + blending.z);
  blending /= vec3(b, b, b);

  vec3 tanX = vec3(-wcNormal.x, -wcNormal.z, wcNormal.y);
  vec3 tanY = vec3( wcNormal.z, wcNormal.y, wcNormal.x);
  vec3 tanZ = vec3(-wcNormal.y, -wcNormal.x, wcNormal.z);

  return tanX * blending.x + tanY * blending.y + tanZ * blending.z;
}

//-----------------------------------------------------------------------------

void main() {
  gl_FragColor = textureCube(reflectionMap, ecNormal);
  vec4 albedo;
  vec2 vTexCoord;
  vec4 lightColor = vec4(0.4, 0.4, 0.4, 1.0);

  if (baseColorMapEnabled) {
    albedo = gammaToLinear(sampleTriPlanar(baseColorMap));
  }
  else {
    albedo = gammaToLinear(baseColor);
  }

  vec3 specular = gammaToLinear(sampleTriPlanar(specularMap)).rgb;

  float glossines = (sampleTriPlanar(glossMap)).r;

  if (custom) {
    glossines = 1.0 - globalRoughness;
    specular = vec3(globalSpecular);
  }

  vec3 normal = sampleTriPlanar(normalMap).rgb * 2.0 - 1.0;
  vec3 eyePos = vec3(0.0, 0.0, -1.0);
  vec3 N = normalize(ecNormal);
  vec3 L = normalize(ecLightPos - ecPosition);
  vec3 V = normalize(eyePos - ecPosition);
  vec3 H = normalize(L + V);

  vec3 T = normalize(triPlanarTangent());
  vec3 B = normalize(cross(wcNormal, T));
  float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
  mat3 TBN = mat3( T * invmax, B * invmax, N );
  if (!custom) {
    N = normalize(TBN * normal);
  }



  float dotNL = clamp(dot(N,L), 0.0, 1.0); //0l
  float dotNV = clamp(dot(N,V), 0.0, 1.0); //0d
  float dotNH = clamp(dot(N,H), 0.0, 1.0); //0h
  float dotLH = clamp(dot(L,H), 0.0, 1.0); //0d
  float dotVH = clamp(dot(V,H), 0.0, 1.0); //== 0d?


  float roughness = 1.0 - glossines;
  float smoothness = glossines;

  //The Schlick Approximation to Fresnel
  float dotLH5 = pow(1.0 - dotLH, 5.0);
  vec3 F0 = specular; //incidence fresnel reflectance
  vec3 Fschlick = F0 + (1.0 - F0) * dotLH5;

  vec3 F = Fschlick;

  //Microfacet Normal Distribution
  float D = 1.0;

  //Specular BRDF: Cook-Torrance microfacet model
  //          D(h) * F(v,h) * G(l,v,h)
  // f(l,v) = ------------------------
  //              4 * n.l * n.v

  //Alpha: Based on \"Real Shading in Unreal Engine 4\"
  float a = pow(1.0 - smoothness * 0.7, 6.0);

  //Normal Distribution Function: GGX
  //                    a^2
  //D(h) = --------------------------------
  //       PI * ((n.h)^2 * (a^2 - 1) + 1)^2
  float aSqr = a * a;
  float Ddenom = dotNH * dotNH * (aSqr - 1.0) + 1.0;
  float Dh = aSqr / ( PI * Ddenom * Ddenom);

  //Diffuse Fresnel (Disney) aka glossy Fresnel
  //Should be 2D lookup texture for IBL as in UnreadEngine4
  float FL = pow((1.0 - dotNL), 5.0);
  float FV = pow((1.0 - dotNV), 5.0);
  float Fd90 = 0.5 + 2.0 * roughness * dotLH*dotLH; //0d
  vec3 Fd = (specularColor).rgb / PI * (1.0 + (Fd90 - 1.0) * FL) * (1.0 + (Fd90 - 1.0) * FV); //0l 0f

  //Fresnel Term: Fresnel Schlick
  //F(v,h) = F0 + (1 - F0)*(1 - (v.h))^5
  //Linear interpolation between specular color F0 and white
  vec3 Fvh = F0 + (1.0 - F0) * pow((1.0 - dotVH), 5.0);

  //Indirect specular
  //vec3 LIndirectSpecular = Fvh * dotNL; //TODO: Fresnel * IBLspec(roughness)

  //Visibility Term: Schlick-Smith
  //                                          n.v               (0.8 + 0.5*a)^2
  //G(l,v,h) = G1(l)* G1(v)    G1(v) = -----------------    k = ---------------
  //                                   (n.v) * (1-k) + k               2
  float k = pow(0.8 + 0.5 * a, 2.0) / 2.0;
  float G1l = dotNL / (dotNL * (1.0 - k) + k);
  float G1v = dotNV / (dotNV * (1.0 - k) + k);
  float Glvn = G1l * G1v;

  //Complete Cook-Torrance
  vec3 flv = Dh * Fvh * Glvn / (4.0 * dotNL * dotNV);

  ////////

  float roughness2 = roughness;//1.0 - (1.0 - roughness) * (1.0 - roughness);
  smoothness = 1.0 - roughness;
  float maxMipMapLevel = 8.0;
  vec4 ambientDiffuse = gammaToLinear(sampleEnvMap(diffuseMap, N, ecPosition, 0.0, material_cubemapSize2));
  vec4 ambientReflection = gammaToLinear(sampleEnvMap(reflectionMap, N, ecPosition, roughness2 * maxMipMapLevel, material_cubemapSize));
  vec4 color = vec4(0.0);
  vec4 ao = texture2D(ssaoMap, gl_FragCoord.xy/windowSize);;
  ao = ao * ao;
  //ao = vec4(1.0);
  //

  color += ao * ambientDiffuse * albedo / PI;
  color += albedo * dotNL * lightColor / PI;
  vec3 Fs = specular + (max(vec3(smoothness), specular) - specular) * pow(1.0 - max(dot(V, N), 0.0), 5.0);
  color = mix(color, ao * ambientReflection * vec4(Fs, 1.0), specular.r);

  gl_FragColor = linearToGamma(color);


  if (show == 1.0) gl_FragColor = vec4(N * 0.5 + 0.5, 1.0);
  if (show == 2.0) gl_FragColor = linearToGamma(albedo);
  if (show == 3.0) gl_FragColor = vec4(glossines);
  if (show == 4.0) gl_FragColor = vec4(specular, 1.0);
  if (show == 5.0) gl_FragColor = linearToGamma(ambientDiffuse);
  if (show == 6.0) gl_FragColor = linearToGamma(ambientReflection);
  if (show == 7.0) gl_FragColor = vec4(dotNL * vec3(pow(1.0 - max(dot(V, N), 0.0), 5.0)), 1.0);
  //if (show == 7.0) gl_FragColor = linearToGamma(vec4(vec3(albedo * dotNL * lightColor / PI), 1.0));
  //if (show == 7.0) gl_FragColor = linearToGamma(vec4(vec3(Fs), 1.0));
  //if (show == 7.0) gl_FragColor = linearToGamma(vec4(albedo * dotNL)); //diffuse
  //if (show == 7.0) gl_FragColor = linearToGamma(vec4(Fs, 1.0) * dotNL); //diffuse
  if (show == 8.0) gl_FragColor = vec4(ao);

  //gl_FragColor = vec4(vec3(flv), 1.0);

  if (skyBox) {
    vec4 ambientReflection = gammaToLinear(sampleEnvMap(reflectionMap, normalize(ecNormal), ecPosition, 1.0, material_cubemapSize2));
    gl_FragColor = linearToGamma(ambientReflection);
    if (show == 1.0) gl_FragColor ;