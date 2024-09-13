#version 410
precision highp float;

out vec4 fragColor;

uniform float iTime;
uniform float iFrame;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform sampler2D iChannel0;

void main() {
    // Output to screen
    fragColor = vec4(float(iFrame) / 1000., 0., 0., 1.0);
}
