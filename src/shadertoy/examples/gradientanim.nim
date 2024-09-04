import shady
import vmath

import shadertoy


proc step*(a, x: float): float =
  if x < a:
    0.0
  else:
    1.0

proc smoothstep*(a, b, x: float): float =
  # Scale, and clamp x to 0..1 range
  let x = clamp((x - a) / (b - a), 0.0, 1.0)
  x * x * (3.0 - 2.0 * x)


proc fragmentShader(
    fragColor: var Vec4,
    gl_FragCoord: Vec4,
    iTime: Uniform[float32],
    iResolution: Uniform[Vec3],
    iMouse: Uniform[IVec2]
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

# test on the CPU:
let iResolution = vec3(width.float32, height.float32, 1.0)
var testColor: Vec4
let fragCoord = vec4(iResolution.x / 2.0, iResolution.y / 2.0, 0.0, 1.0)
fragmentShader(testColor, fragCoord, 0.0, iResolution, ivec2(0, 0))
echo testColor

# compile to a GPU shader:
var shader = toGLSL(fragmentShader)
echo shader
# and run demo
run("Animated Gradient", shader, width, height)
