#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float fs_elevation;
out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// Returns dstToSphere, dstThroughSphere
// If inside sphere, dstToSphere will be 0
// If ray misses sphere, dstToSphere = max float value, dstThroughSphere = 0
// Given rayDir must be normalized
vec2 raySphere(vec3 centre, float radius, vec3 rayOrigin, vec3 rayDir) {
    vec3 offset = rayOrigin - centre;
    const float a = 1.0; // set to dot(rayDir, rayDir) instead if rayDir may not be normalized
    float b = 2.0 * dot(offset, rayDir);
    float c = dot (offset, offset) - radius * radius;

    float discriminant = b*b-4.0*a*c;
    // No intersections: discriminant < 0
    // 1 intersection: discriminant == 0
    // 2 intersections: discriminant > 0
    if (discriminant > 0.0) {
        float s = sqrt(discriminant);
        float dstToSphereNear = max(0.0, (-b - s) / (2.0 * a));
        float dstToSphereFar = (-b + s) / (2.0 * a);

        if (dstToSphereFar >= 0.0) {
            return float2(dstToSphereNear, dstToSphereFar - dstToSphereNear);
        }
    }
	 // Ray did not intersect sphere
    return float2(maxFloat, 0.0);
}



void main()
{
         // Compute final shaded color
        vec4 col;
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 0.8;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.


        out_Col = vec4(diffuseColor.rgb* lightIntensity, diffuseColor.a);
}
