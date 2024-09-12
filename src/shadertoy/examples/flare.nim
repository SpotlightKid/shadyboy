# from https://www.shadertoy.com/view/XsXXDn by 'Danilo Guanabara'

import shady
import vmath

import shadertoy


proc flare(
    fragColor: var Vec4,
    gl_FragCoord: Vec4,
    uv: Vec2,
    iTime: Uniform[float32],
    iResolution: Uniform[Vec3],
    iMouse: Uniform[Vec4]
  ) =
  var
    c: Vec3
    l: float32
    z = iTime

  for i in 0 ..< 3:
    var
      p = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y
      pos = p

    z += 0.07
    l = length(p)
    pos += p / l * (sin(z) + 1.0) * abs(sin(l * 9.0 - z * 2.0))
    c[i] = 0.01 / length(abs(vec2(pos) mod vec2(1.0)) - 0.5)

  let v = c/l
  fragColor = vec4(v.x, v.y, v.z, iTime)

let
  width = 800
  height = 600

#[
# test on the CPU:
let iResolution = vec3(width.float32, height.float32, 1.0)

var testColor: Vec4

flare(testColor, vec2(100, 100), 0.0, iResolution)
echo testColor
]#

# compile to a GPU shader:
var shaderSrc = toGLSL(flare)
#echo shaderSrc

runWithShaderToy("flare", width, height, shaderSrc)
