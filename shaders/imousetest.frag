#version 410
precision highp float;

out vec4 fragColor;

uniform float iTime;
uniform float iFrame;
uniform vec3 iResolution;
uniform vec4 iMouse;
uniform sampler2D iChannel0;

// declare mainImage function here so we can have main at the top of the script
void mainImage(out vec4 fragColor, in vec2 fragCoord);

void main() {
    mainImage(fragColor, gl_FragCoord.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 col;
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (2. * fragCoord.xy - iResolution.xy) / iResolution.y;
    vec2 mv = (2. * iMouse.xy - iResolution.xy) / iResolution.y;
    vec2 mz = iMouse.zw / iResolution.xy;


    // Output to screen
    if (uv.x > 0.)
      col = vec4(mv.x, mv.y, 0.0, 1.0);
    else
      if (uv.y > 0.)
        col = vec4(abs(mz.x), abs(mz.y), 0.0, 1.0);
      else
        col = vec4(mz.x, mz.y, 0.0, 1.0);

    fragColor = col;
}
