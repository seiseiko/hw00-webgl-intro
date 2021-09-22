#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform float u_Time;       // Current time
uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.


// FBM start
float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }


vec4 mod289(vec4 x){
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 perm(vec4 x){
    return mod289(((x * 34.0) + 1.0) * x);
}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

#define OCTAVES 15
float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100.0);
	for (int i = 0; i < OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

// 3D FBM end

// calculate rotation matrix
mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    // offset the vertices to form biomes
    float noise = fbm(vec3(sin(0.005*u_Time))+vec3(vs_Pos)); 
    vec4 pos = vs_Pos;
    // creating some building like stuff
    if(noise>0.9){                
        pos = pos + fs_Nor*noise*0.3;
        fs_Col = vec4(0.1059, 0.5804, 0.2627, 1.0);   
    }
    else if(noise>0.80){                
        pos = pos + fs_Nor*noise*0.3;
        fs_Col = vec4(0.4941, 0.9216, 0.549, 1.0);   
    }
    else if(noise>0.75){                 
        pos = pos + fs_Nor*noise*0.3;
        fs_Col = vec4(0.5922, 0.7216, 0.8941, 1.0);   
    }
    else if(noise>0.65){                 
        pos = pos + fs_Nor*noise*0.3;
        fs_Col = vec4(1.0, 1.0, 1.0, 1.0);   
    }
    else if (noise > 0.54){
        pos = pos + fs_Nor*noise*0.2; 
        fs_Col = vec4(1.0, 1.0, 1.0, 1.0);    
    }
    else if (noise > 0.5){
        pos = pos + fs_Nor*noise*0.2; 
        fs_Col = vec4(0.7608, 0.8549, 0.9686, 1.0);    
    }
    else if (noise > 0.38){
        pos = pos + fs_Nor*noise*0.2; 
        fs_Col = vec4(0.4118, 0.6902, 0.8784, 0.925);    
    }
    else if (noise > 0.35){
        pos = pos + fs_Nor*noise*0.1; 
        fs_Col = vec4(0.2196, 0.3373, 0.7255, 1.0);    
    }
    else if (noise > 0.15){
        pos = pos + fs_Nor*noise*0.1; 
        fs_Col = vec4(0.0863, 0.2, 0.8471, 1.0);    
    }
    else if(noise < 0.15){
        pos = pos - fs_Nor*noise*0.2;
        fs_Col = vec4(0.0, 0.0, 0.0, 1.0);  
    }
    
    vec4 modelposition = u_Model * pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies
    fs_Pos = modelposition;
    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}