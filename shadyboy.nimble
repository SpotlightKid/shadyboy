# Package

version       = "0.1.0"
author        = "Christopher Arndt"
description   = "Nim desktop shadertoy fragment shader player"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"

# Dependencies

requires "nim >= 2.0.0"
requires "opengl >= 1.2.2"
requires "pixie"
requires "https://github.com/SpotlightKid/shady.git#local"
requires "vmath"
requires "windy"
requires "https://bitbucket.org/maxgrenderjones/therapist.git#head"

# Binaries

namedBin = toTable({
  "shadyboy": "shadyboy",
  "shadyboy/examples/circlesdf": "shadyboy-circlesdf",
  "shadyboy/examples/flare": "shadyboy-flare",
  "shadyboy/examples/gradientanim": "shadyboy-gradientanim",
})

task examples, "List examples":
    for _, name in namedBin:
        echo("* " & name)
