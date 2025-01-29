#ifdef GL_ES
precision mediump float;
#endif

// Copyright (c) Patricio Gonzalez Vivo, 2015 - http://patriciogonzalezvivo.com/
// I am the sole copyright owner of this Work.
//
// You cannot host, display, distribute or share this Work in any form,
// including physical and digital. You cannot use this Work in any
// commercial or non-commercial product, website or project. You cannot
// sell this Work and you cannot mint an NFTs of it.
// I share this Work for educational purposes, and you can link to it,
// through an URL, proper attribution and unmodified screenshot, as part
// of your educational material. If these conditions are too restrictive
// please contact me and we'll definitely work it out.


uniform vec2 u_resolution; // Screen resolution
varying vec2 vUv;          // UV coordinates from vertex shader
uniform float u_time;
#define PI 3.14159265358979323846


// Function to rotate UV coordinates
vec2 rotate2D(vec2 _st, float _angle){
    _st -= 0.5;  // Center the UV coordinates to (0, 0)
    _st = mat2(cos(_angle), -sin(_angle), sin(_angle), cos(_angle)) * _st;
    _st += 0.5;  // Re-center back
    return _st;
}

// Function to create a tile pattern (zoomable)
vec2 tile(vec2 _st, float _zoom){
    _st *= _zoom;
    return fract(_st);  // Ensures the pattern repeats
}

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

void main(void) {
    vec2 uv = vUv; // Use normalized UV coordinates
    
    // Define the triangle's parameters (equilateral)
    float side = 0.1;  // Side length of the triangle
    float height = sqrt(3.0) / 2.0 * side;
    vec2 center = vec2(0.4, 0.6);  // Triangle center at (0, 0)

    // Define the triangle vertices
    vec2 v1 = center + vec2(0.0, side);             // Top vertex
    vec2 v2 = center + vec2(0.0, 0.0);    // Bottom-left
    vec2 v3 = center + vec2(height, side /2.0);     // Bottom-right

    // triangle 2
    vec2 v21 = center + vec2(height, 0.1);             // Top vertex
    vec2 v22 = center + vec2(height, -0.1);    // Bottom-left
    vec2 v23 = center + vec2(height+height, 0.0);     // Bottom-right

    vec2 diff = vec2(height, -side / 2.0);
    vec2 diff2 = vec2(0.0, -side);


    // Check if the current fragment lies inside the triangle
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

    // Tile size for the grid pattern
    float tileSize = 0.1;
    uv = tile(uv, 1.0);  // Zoom in for a finer grid

    // Rotate the UV coordinates to create a rotated pattern
    float angle = PI / 4.0;  // Rotate 45 degrees
    uv = rotate2D(uv, angle);

    // Create a simple checkerboard pattern (alternating black and white)
    float pattern = step(0.7, step(0.5, mod( floor(uv.x / tileSize) + floor( uv.y / tileSize), 2.0)));  

    // Only display the pattern inside the triangle
    if (inside > 0.0 || inside2 > 0.0 || inside3 > 0.0 || inside4 > 0.0 || inside5 > 0.0 || inside6 > 0.0 || inside7 > 0.0 || inside8 > 0.0 || inside9 > 0.0 ||inside10>0.0) {
        vec3 color = vec3(1.0, 0.954, 0.05); // Use checkerboard for the inside
        gl_FragColor = vec4(color, 1.0);
    } else {
        gl_FragColor = vec4(0.024, 0.07, 0.229, 1.0);  // Black outside the triangle
    }
}
