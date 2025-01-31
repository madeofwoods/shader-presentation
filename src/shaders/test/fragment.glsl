precision mediump float;

uniform vec3 uColor;
uniform sampler2D uTexture;
uniform int uToggleTexture;
uniform int uToggleUV;

varying vec2 vUv;
varying float vElevation;
varying float vRandom;


void main() 
{
    vec4 textureColor = vec4(0.5,0.4, 0.8, 1.0);
    textureColor = vec4(0.5+ vElevation,0.2+ vElevation, 0.9, 1.0);

    if (uToggleUV == 1) {
        textureColor = vec4(vUv.x, vUv.y, 0.0, 1.0);
        }
    

    gl_FragColor = textureColor;

}   