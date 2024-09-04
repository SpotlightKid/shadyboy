## Inspired by https://www.shadertoy.com/

import std/times

import opengl
import windy
import vmath

let
  vertices: seq[float32] = @[
    -1f, -1f, #1.0f, 0.0f, 0.0f,
    +1f, -1f, #0.0f, 1.0f, 0.0f,
    +1f, +1f, #0.0f, 0.0f, 1.0f,
    +1f, +1f, #1.0f, 0.0f, 0.0f,
    -1f, +1f, #0.0f, 1.0f, 0.0f,
    -1f, -1f, #0.0f, 0.0f, 1.0f
  ]

var
  program: GLuint
  vPosLocation: GLint
  iResLocation: GLint
  iMouseLocation: GLint
  iTimeLocation: GLint
  window: Window
  isPaused: bool = false
  startTime, currentTime, pausedTime: float64
  vertexArrayId: GLuint


proc checkError*(shader: GLuint): int =
  var code: GLint
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr code)

  if code.GLboolean == GL_FALSE:
    var length: GLint = 0
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr length)
    var log = newString(length.int)
    glGetShaderInfoLog(shader, length, nil, log.cstring)
    echo log
    return 1

  return 0


proc start(title, vertexShaderText, fragmentShaderText: string, width, height: int) =
  window = newWindow(
    title = title,
    size = ivec2(width.int32, height.int32),
    visible = true
  )
  # Connect the GL context.
  window.makeContextCurrent()

  when not defined(emscripten):
    # This must be called to make any GL function work
    loadExtensions()

  var vertexShader = glCreateShader(GL_VERTEX_SHADER)
  var vertexShaderTextArr = allocCStringArray([vertexShaderText])
  glShaderSource(vertexShader, 1.GLsizei, vertexShaderTextArr, nil)
  glCompileShader(vertex_shader)
  doAssert checkError(vertexShader) == 0

  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
  var fragmentShaderTextArr = allocCStringArray([fragmentShaderText])
  glShaderSource(fragmentShader, 1.GLsizei, fragmentShaderTextArr, nil)
  glCompileShader(fragmentShader)
  doAssert checkError(fragment_shader) == 0

  program = glCreateProgram()
  glAttachShader(program, vertexShader)
  glAttachShader(program, fragmentShader)
  glLinkProgram(program)

  vPosLocation = glGetAttribLocation(program, "vPos")
  iResLocation = glGetUniformLocation(program, "iResolution")
  iMouseLocation = glGetUniformLocation(program, "iMouse")
  iTimeLocation = glGetUniformLocation(program, "iTime")

  glGenVertexArrays(1, vertexArrayId.addr)
  glBindVertexArray(vertexArrayId)

  var vertexBuffer: GLuint
  glGenBuffers(1, addr vertexBuffer)
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
  glBufferData(
    GL_ARRAY_BUFFER,
    vertices.len * 5 * 4,
    vertices[0].unsafeAddr,
    GL_STATIC_DRAW
  )
  glVertexAttribPointer(
    vPosLocation.GLuint,
    2.GLint,
    cGL_FLOAT,
    GL_FALSE,
    0.GLsizei,
    nil
  )

  glEnableVertexAttribArray(vPosLocation.GLuint)

  startTime = epochTime()


proc display() =
  glViewport(0, 0, window.size.x, window.size.y)
  glClearColor(0, 0, 0, 1)
  glClear(GL_COLOR_BUFFER_BIT)

  let now = epochTime()

  if isPaused:
    pausedTime += now - startTime - currentTime

  currentTime = now - startTime

  let ratio = window.size.x.float / window.size.y.float
  let mpos = window.mousePos()

  glUseProgram(program)
  glUniform3f(iResLocation.GLint, window.size.x.GLfloat, window.size.y.GLfloat, ratio.GLfloat)
  glUniform2i(iMouseLocation.GLint, mpos.x, mpos.y)
  glUniform1f(iTimeLocation, float32(currentTime - pausedTime))
  glDrawArrays(GL_TRIANGLES, 0, 6)

  window.swapBuffers()


proc run*(title, shader: string, width: int, height: int) =
  var vertexShader = """
  #version 410
  precision highp float;

  in vec3 vPos;
  uniform vec3 iResolution;
  uniform ivec2 iMouse;

  void main() {
    gl_Position = vec4(vPos.x, vPos.y, 0.0, 1.0);
  }
  """

  #echo vertexShader
  start(title, vertexShader, shader, width, height)

  window.onButtonPress = proc(button: Button) =
    #echo "onButtonPress ", button

    case button:
    of KeyF11, KeyF:
      window.fullscreen = not window.fullscreen
    of KeyEscape, KeyQ:
      window.closeRequested = true
      return
    of KeySpace:
      isPaused = not isPaused
      return
    else:
      discard

  while not window.closeRequested:
    display()
    pollEvents()
