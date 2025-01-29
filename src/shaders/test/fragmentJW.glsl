
varying vec2 vUv;          // UV coordinates from vertex shader
uniform float uTime;
varying float vElevation;


// Edge function to check if UV is inside a triangle (equilateral)
float insideTriangle(vec2 uv, vec2 v1, vec2 v2, vec2 v3) {
    float edge1 = (v2.x - v1.x) * (uv.y - v1.y) - (v2.y - v1.y) * (uv.x - v1.x);
    float edge2 = (v3.x - v2.x) * (uv.y - v2.y) - (v3.y - v2.y) * (uv.x - v2.x);
    float edge3 = (v1.x - v3.x) * (uv.y - v3.y) - (v1.y - v3.y) * (uv.x - v3.x);

    if (edge1 >= 0.0 && edge2 >= 0.0 && edge3 >= 0.0) {
        return 1.0;  // Inside triangle
    }
    return 0.0;  // Outside triangle
}

bool isInside(vec2 uv) {
    
    // Define the triangle's parameters (equilateral)
    float side = 0.09;  // Side length of the triangle
    float height = sqrt(3.0) / 2.0 * side;
    vec2 center = vec2(0.4, 0.6);  // Triangle center at (0, 0)

    float modTime = uTime == 0.0 ? 0.0 : abs(mod(uTime, 4.0) - 2.0)*0.0032;
    modTime = 0.0;
    // Define the triangle vertices
    vec2 v1 = center + vec2(0.0+modTime, side-modTime);             // Top vertex
    vec2 v2 = center + vec2(0.0+modTime, 0.0);    // Bottom-left
    vec2 v3 = center + vec2(height, (side+modTime) /2.0);     // Bottom-right


    vec2 diff = vec2(height+0.01+modTime, (-side-0.01+ modTime) / 2.0);
    vec2 diff2 = vec2(0.0-modTime, -side-0.01 - modTime);
    float inside = insideTriangle(uv, v1, v2, v3);
    float inside2 = insideTriangle(uv, v1+diff, v2 + diff, v3 + diff);
    float inside3 = insideTriangle(uv, v1+diff+diff, v2 +diff+diff, v3  +diff+diff);
    float inside4 = insideTriangle(uv, v1+diff2, v2 + diff2, v3 + diff2);
    float inside5 = insideTriangle(uv, v1+diff2+diff2, v2 + diff2+diff2, v3 + diff2+diff2);
    float inside6 = insideTriangle(uv, v1+ diff+ diff2, v2 + diff+diff2, v3 + diff+diff2);
    float inside7 = insideTriangle(uv, v1+ (diff2 * 3.0), v2 + (diff2 * 3.0), v3 + (diff2 * 3.0));
    float inside8 = insideTriangle(uv, v1+(diff2*2.0+diff), v2 + (diff2*2.0+diff), v3 + (diff2*2.0+diff));
    float inside9 = insideTriangle(uv, v1+ diff2+ diff*2.0, v2 + diff2+ diff*2.0, v3 + diff2+ diff*2.0);
    float inside10 = insideTriangle(uv, v1+ diff*3.0, v2 + diff*3.0, v3 + diff*3.0);

    return inside > 0.0 || inside2 > 0.0 || inside3 > 0.0 || inside4 > 0.0 || inside5 > 0.0 || inside6 > 0.0 || inside7 > 0.0 || inside8 > 0.0 || inside9 > 0.0 ||inside10>0.0;

}

void main(void) {
    vec2 uv = vUv; // Use normalized UV coordinates
    // Only display the pattern inside the triangle
    if (isInside( vUv)) {
        vec3 color = vec3(1.0, 0.954, 0.05); // Use checkerboard for the inside
        color.g -= vElevation * 1.3;
        gl_FragColor = vec4(color, 1.0);
    } else {
        vec3 background = vec3(0.024, 0.07, 0.229);  // Dark blue background
        background.rgb *= vElevation * 3.1 + 0.8;
        gl_FragColor = vec4(background, 1.0);  // Black outside the triangle
    }
}
