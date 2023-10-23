#version 150

uniform mat4 transformMatrix;
uniform mat4 modelviewMatrix;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8];
uniform float time;

in vec4 position;
in vec4 color;
in vec3 normal;
in vec2 texCoord;
 
uniform vec3 lightDirection;
uniform mat4 shadowTransform;

// uniform sampler2D materialMap;    // combined materials texture
uniform sampler2D normalMap;    // combined materials texture

 
out FragData {
  vec4 color;
  vec3 ecVertex;
  vec3 normal;
  vec2 texCoord;
  vec4 shadowCoord;
  float lightIntensity;
} FragOut;
 


void main() {

  // float disp = texture(materialMap, texCoord).g;
  // float disp = texture(normalMap, texCoord).g;
  // vec4 displace = position;

  // float displaceFactor = 50.f;
  // float displaceBias = 0;
  // displace.xyz += (displaceFactor * disp - displaceBias) * normal;

  // gl_Position = transformMatrix * displace;
  // vec3 ecp = vec3(modelviewMatrix * displace);
  gl_Position = transformMatrix * position;
  vec3 ecp = vec3(modelviewMatrix * position);
  
  // vec4 vertPosition = modelview * vertex;// Get vertex position in model view space
  vec4 vertPosition = modelviewMatrix * position;
  vec3 vertNormal = normalize(normalMatrix * normal);// Get normal direction in model view space
  FragOut.lightIntensity = 0.5 + dot(-lightDirection, vertNormal) * 0.5;
  // FragOut.lightIntensity = dot(-lightDirection, vertNormal);
  // FragOut.lightIntensity = .9f;
  FragOut.shadowCoord = shadowTransform * (vertPosition + vec4(vertNormal, 0.0));// Normal bias removes the shadow acne
  
  FragOut.ecVertex = ecp;
  FragOut.normal = normalize(normalMatrix * normal);
  FragOut.color =  color;
  FragOut.texCoord = (texMatrix * vec4(texCoord, 1.0, 1.0)).st;
  
}