# from https://www.shadyboy.com/view/XsXXDn by 'Danilo Guanabara'

import shady
import vmath

import shadyboy


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


runWithShadyBoy(toGLSL(flare), "Flare")
