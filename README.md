# Shadyboy

A Nim shader toy, that is an *OpenGL* desktop application implemented in [Nim]
allowing to run [GLSL] shaders from [Shadertoy] on the desktop with only little
changes but potentially better performance than in the browser. Shaders can
also be implemented in Nim and are translated to GLSL on-the-fly.

This is currently in alpha stage and only supports basic shadertoy.com shaders,
which do not use more than one texture and no additional source files, sounds
or maps.


## Getting started

## Build

    nimble build -d:release

## Run the included Nim examples

    nimble run -d:release shadyboy-<name>

Run `nimble examples` to list available examples.

## Run the included GLSL fragment shaders examples

    nimble run -d:release shadyboy shaders/<name>.frag

You can also build the `shadytoy` program once and then use it to run the
shader files:

    nimble build -d:release shadyboy

And then:

    ./bin/shadytoy shaders/<name>.frag

## Run shaders from shadertoy.com

* Find a shader you like on https://shadertoy.com, which only has one "Image"
  source code tab and doesn't use any textures, sounds or maps.
* Copy the shader code from the "Image" tab and save it to a file, e.g.
  `shader.frag`.
* Open the file in a source code editor and add the following code at the
  beginning of the file:

```glsl
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
```

Run the shader file with `shadyboy` as shown above, e.g.:

    nimble run -d:release shadyboy shader.frag

## Command-line Options

```
$ ./bin/shadyboy --help
Usage:
  shadyboy <shader>
  shadyboy (--help)

Arguments:
  <shader>              Fragment shader source path

Options:
  -x, --texture=<file>  Texture image file path
  -t, --title=<title>   Window title
  -w, --width=<px>      Window width in pixels [default: 800]
  -h, --height=<px>     Window height in pixels [default: 600]
  -v, --verbose...      Verbose output
      --help            Show help message
```

## Interactive Controls

| Control                   | Action                                                              |
| ------------------------- | ------------------------------------------------------------------- |
| `ESC / q`                 | Quit program                                                        |
| `F11 / f`                 | Toggle full-screen window                                           |
| `SPACE`                   | Toggle pause animation timer (`iTime`) and frame counter (`iFrame`) |
| Left mouse click-and-drag | Manipulate `iMouse` shader uniform ([how does it work?])            |

[how does it work?]: https://shadertoyunofficial.wordpress.com/2016/07/20/special-shadertoy-features/


## Requirements

### Building

Dependencies besides Nim, [nimble] and the C compiler itself are automatically
resolved and installed by nimble.

* Nim 2.0+ and `nimble`
* opengl
* windy
* pixie
* shady
* therapist
* vmath

### Runtime

* `libc` (dynamically linked)
* OpenGL (`libGL`)\*
* `libX11`\* (Linux)
* `libXext`\* (Linux)

\* Loaded dynamically via `dlopen`.


[glsl]: https://registry.khronos.org/OpenGL/index_gl.php#apispecs
[nimble]: https://nim-lang.github.io/nimble/
[nim]: https://nim-lang.org
[shadertoy]: https://www.shadertoy.com/
