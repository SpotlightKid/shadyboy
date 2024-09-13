# Shadyboy

A Nim shader toy, that is an *OpenGL* desktop application implemented in [Nim]
allowing to run [GLSL] shaders from [Shadertoy] on the desktop with only little
changes but much better performance than in the browser. Shaders can also
implemented in Nim and are translated to GLSL on-the-fly.

This is currently in alpha stage and only supports basic shaders, which
do not use more than one textures or additional sounds or maps.


## Getting started

## Build

    nimble build -d:release

## Run the Nim examples

    nimble run -d:release shadyboy-<name>

Run `nimble examples` to list available examples.


## Run shadertoy GLSL fragment shaders directly

    nimble run -d:release shadyboy shaders/<name>.frag

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

* libc (dynamically linked)
* OpenGL (libGL)\*
* libX11\*
* libXext\*

\* loaded dynamically via `dlopen`


[glsl]: https://registry.khronos.org/OpenGL/index_gl.php#apispecs
[nimble]: https://nim-lang.github.io/nimble/
[nim]: https://nim-lang.org
[shadertoy]: https://www.shadertoy.com/
