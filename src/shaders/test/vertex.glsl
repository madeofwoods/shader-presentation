uniform vec2 uFrequency;
uniform float uTime;
uniform int uEnableElevation;
uniform float uRandom;
uniform float uBigWaveElevation;
uniform int uWater;


attribute float aRandom;

varying float vRandom;
varying vec2 vUv;
varying float vElevation;


void main()
{
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);


    float random = aRandom * uRandom ;

    float elevation = 0.0;

    elevation += sin(modelPosition.x * uFrequency.x - uTime) * 0.1;
    elevation += sin(modelPosition.y * uFrequency.y ) * 0.1;

    modelPosition.z += elevation;

    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    
    gl_Position = projectedPosition;

    vRandom = random;

    vUv = uv;
    vElevation = uEnableElevation == 1 ? elevation :  0.0;

}

