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
  var uv = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y
  # Single circle SDF
  var circle = vec3(0.0, 0.0, 0.3)
  var d = length(uv - circle.xy) - circle.z
  # Sharp circle
  #d = step(0.0, d)
  # Smooth circle
  d = abs(d)
  d = smoothstep(0.0, 0.02, d)
  fragColor = vec4(d, d, d, 1.0)


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
run("circle SDF", shader, width, height)
