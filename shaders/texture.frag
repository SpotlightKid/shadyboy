#version 410
precision highp float;

out vec4 fragColor;

uniform vec3 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;
uniform sampler2D iChannel0;

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv.y *= -1;
    fragColor = texture(iChannel0, uv);
}
