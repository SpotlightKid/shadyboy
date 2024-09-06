# Package

version       = "0.1.0"
author        = "Christopher Arndt"
description   = "Nim shadertoy"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"

# Dependencies

requires "nim >= 2.0.0"
requires "opengl >= 1.2.2"
requires "https://github.com/SpotlightKid/shady.git#local"
requires "windy"

# Binaries

namedBin = toTable({
  "shadertoy/examples/circlesdf": "shadertoy-circlesdf",
  "shadertoy/examples/flare": "shadertoy-flare",
  "shadertoy/examples/gradientanim": "shadertoy-gradientanim",
})
