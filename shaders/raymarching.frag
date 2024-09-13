#version 410
precision highp float;

out vec4 fragColor;

uniform float iTime;
uniform float iFrame;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform sampler2D iChannel0;

#define MAX_ITERATIONS 100
#define MIN_DISTANCE 0.001
#define MAX_DISTANCE 50.0
#define CAMERA_DISTANCE 4


// 2D rotation
mat2 rot2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

// Octahedron SDF - https://iquilezles.org/articles/distfunctions/
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
}

// Scene distance
float map(vec3 p) {
    return sdOctahedron(p, 2.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    vec2 mv = (iMouse.xy * 2. - iResolution.xy) / iResolution.y * 2.0;

    // Initialization
    // ray origin
    vec3 ro = vec3(0.0, 0.0, -CAMERA_DISTANCE);
    // ray direction
    vec3 rd = normalize(vec3(uv, 1.0));
    // final pixel color
    vec3 col = vec3(0.0);

    // total distance travelled
    float t = 0.;

    // Vertical camera rotation
    ro.yz *= rot2D(-mv.y);
    rd.yz *= rot2D(-mv.y);

    // Horizontal camera rotation
    ro.xz *= rot2D(-mv.x);
    rd.xz *= rot2D(-mv.x);

    // Do ray marching
    int i;
    for (i = 0; i < MAX_ITERATIONS; i++) {
        // position along the ray
        vec3 p = ro + rd * t;
        // current distance to the scene
        float d = map(p);
        // "march" the ray
        t += d;

        // early stop if close enough or too far
        if (d < MIN_DISTANCE || t > MAX_DISTANCE) break;
    }

    // Coloring based on distance
    col = vec3(t * 0.04 + float(i) * 0.01);

    fragColor = vec4(col, 1);
}

void main() {
    mainImage(fragColor, gl_FragCoord.xy);
}
