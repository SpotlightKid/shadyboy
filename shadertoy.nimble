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
requires "https://bitbucket.org/maxgrenderjones/therapist.git#head"

# Binaries

namedBin = toTable({
  "shadertoy": "shadertoy",
  "shadertoy/examples/circlesdf": "shadertoy-circlesdf",
  "shadertoy/examples/flare": "shadertoy-flare",
  "shadertoy/examples/gradientanim": "shadertoy-gradientanim",
})

task examples, "List examples":
    for _, name in namedBin:
        echo("* " & name)
