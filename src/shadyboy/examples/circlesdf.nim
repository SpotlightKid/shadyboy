# Demonstrates how to draw circles with a Signed Distance Function (SDF)

import shady
import vmath

import shadyboy


proc step*(a, x: float): float =
  if x < a:
    0.0
  else:
    1.0


proc smoothstep*(a, b, x: float): float =
  # Scale, and clamp x to 0..1 range
  let x = clamp((x - a) / (b - a), 0.0, 1.0)
  x * x * (3.0 - 2.0 * x)


proc circleSDF(p: Vec2, r: float): float =
  length(p) - r


proc fragmentShader(
    fragColor: var Vec4,
    gl_FragCoord: Vec4,
    iTime: Uniform[float32],
    iResolution: Uniform[Vec3],
    iMouse: Uniform[Vec4]
  ) =
  var uv = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y
  # Filled circle with sharp edge
  var d1 = circleSDF(uv - vec2(0.5, 0.0), 0.3)
  d1 = step(0.0, d1)
  # Circle with soft line
  var d2 = circleSDF(uv - vec2(-0.5, 0.0), 0.3)
  d2 = smoothstep(0.0, 0.02, abs(d2))
  let col = vec3(min(d1, d2))
  fragColor = vec4(col.r, col.g, col.b, 1.0)


runWithShaderToy(toGLSL(fragmentShader), title="Circle SDF")
