# Default newly created shadertoy.com shader re-implemented in Nim

import shady
import vmath

import shadyboy


proc fragmentShader(
    fragColor: var Vec4,
    gl_FragCoord: Vec4,
    iTime: Uniform[float32],
    iResolution: Uniform[Vec3],
    iMouse: Uniform[Vec4]
  ) =
  # Normalized pixel coordinates (from 0 to 1)
  var uv = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y
  # Time varying pixel color
  var col = cos(iTime + uv.xyx + vec3(0, 2, 4)) * 0.5 + 0.5
  # Output to screen
  fragColor = vec4(col.r, col.g, col.b, 1.0)


let
  width = 800
  height = 600

# Test on the CPU:
let iResolution = vec3(width.float32, height.float32, 1.0)
var testColor: Vec4
let fragCoord = vec4(iResolution.x / 2.0, iResolution.y / 2.0, 0.0, 1.0)
fragmentShader(testColor, fragCoord, 0.0, iResolution, vec4(0.0, 0.0, 0.0, 0.0))
echo testColor

# Compile to GLSL source:
var shaderSrc = toGLSL(fragmentShader)
echo shaderSrc

# And run it:
runWithShaderToy(shaderSrc, title="Animated Gradient")
