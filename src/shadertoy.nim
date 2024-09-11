## Inspired by https://www.shadertoy.com/

import std/[files, paths, strformat, tables, times]

import opengl
import pixie except Path
import therapist
import windy
import vmath

const vertexShaderSrc = """
#version 410

in vec3 vertexPos;
in vec2 vertexUv;

out vec3 vPos;
out vec2 vUv;

void main()
{
  vPos = vertexPos;
  vUv = vertexUv;
  gl_Position = vec4(vertexPos.xyz, 1.0);
}
"""

let
  vertices: seq[float32] = @[
    -1f, -1f,
    +1f, -1f,
    +1f, +1f,
    +1f, +1f,
    -1f, +1f,
    -1f, -1f,
  ]
  uvData: seq[Vec2] = @[
    vec2(0f, 1f),
    vec2(1f, 1f),
    vec2(1f, 0f),
    vec2(1f, 0f),
    vec2(0f, 0f),
    vec2(0f, 1f)
  ]

type shaderProgram* = ref object
  programId*: GLuint
  vertexShaderId*: GLuint
  fragmentShaderId*: GLuint
  attributes*: Table[string, GLint]
  uniforms*: Table[string, GLint]

type ShaderToy* = ref object
  window*: Window
  program*: shaderProgram
  vertexArrayId*: GLuint
  texturePath: string
  textureId*: int
  startTime*, elapsedTime*, pausedTime*: float64
  isPaused*: bool = false
  mouseDown: bool
  lastClickPos: Vec2


proc checkError*(shader: GLuint): int =
  var code: GLint
  glGetShaderiv(shader, GL_COMPILE_STATUS, code.addr)

  if code.GLboolean == GL_FALSE:
    var logLength: GLint = 0
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, logLength.addr)
    var log = newString(logLength.int)
    glGetShaderInfoLog(shader, logLength, nil, log.cstring)
    echo log
    return 1

  return 0


proc checkLinkError*(program: GLuint): int =
  ## Checks the shader for errors.
  var code: GLint
  glGetProgramiv(program, GL_LINK_STATUS, addr code)

  if code.GLboolean == GL_FALSE:
    var length: GLint = 0
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, addr length)
    var log = newString(length.int)
    glGetProgramInfoLog(program, length, nil, log.cstring)
    echo log
    return 1

  return 0


proc newShaderProgram*(
    vertexShaderSrc: string, fragmentShaderSrc: string
): shaderProgram =
  var vertexShaderId = glCreateShader(GL_VERTEX_SHADER)
  var vertexShaderSrcArr = allocCStringArray([vertexShaderSrc])
  glShaderSource(vertexShaderId, 1.GLsizei, vertexShaderSrcArr, nil)
  glCompileShader(vertexShaderId)
  doAssert checkError(vertexShaderId) == 0

  var fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER)
  var fragmentShaderSrcArr = allocCStringArray([fragmentShaderSrc])
  glShaderSource(fragmentShaderId, 1.GLsizei, fragmentShaderSrcArr, nil)
  glCompileShader(fragmentShaderId)
  doAssert checkError(fragmentShaderId) == 0

  var programId = glCreateProgram()
  glAttachShader(programId, vertexShaderId)
  glAttachShader(programId, fragmentShaderId)
  glLinkProgram(programId)
  doAssert checkLinkError(programId) == 0

  result = shaderProgram()
  result.programId = programId
  result.vertexShaderId = vertexShaderId
  result.fragmentShaderId = fragmentShaderId
  result.attributes = initTable[string, GLint]()
  result.attributes["vertexPos"] = glGetAttribLocation(programId, "vertexPos")
  result.attributes["vertexUv"] = glGetAttribLocation(programId, "vertexUv")

  result.uniforms = initTable[string, GLint]()
  result.uniforms["iResolution"] = glGetUniformLocation(programId, "iResolution")
  result.uniforms["iMouse"] = glGetUniformLocation(programId, "iMouse")
  result.uniforms["iTime"] = glGetUniformLocation(programId, "iTime")
  result.uniforms["iChannel0"] = glGetUniformLocation(programId, "iChannel0")


proc loadTexture*(path: string): GLuint =
  var textureId: GLuint
  let textureImg = readImage(path)

  glGenTextures(1, textureId.addr)
  glBindTexture(GL_TEXTURE_2D, textureId)

  # set the texture wrapping/filtering options
  # (on the currently bound texture object)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)

  # load and generate the texture
  glTexImage2D(
    target = GL_TEXTURE_2D,
    level = 0,
    internalFormat = GL_RGBA8.GLint,
    width = textureImg.width.GLsizei,
    height = textureImg.height.GLsizei,
    border = 0,
    format = GL_RGBA,
    `type` = GL_UNSIGNED_BYTE,
    pixels = cast[pointer](textureImg.data[0].addr),
  )
  glGenerateMipmap(GL_TEXTURE_2D)
  result = textureId

proc newShaderToy*(
    fragmentShaderSrc: string,
    title: string,
    width: int,
    height: int,
    texturePath: string,
): ShaderToy =
  result = ShaderToy()
  result.window =
    newWindow(title = title, size = ivec2(width.int32, height.int32), visible = true)
  # Connect the GL context.
  result.window.makeContextCurrent()

  when not defined(emscripten):
    # This must be called to make any GL function work
    loadExtensions()

  result.program = newShaderProgram(vertexShaderSrc, fragmentShaderSrc)

  # Set up shader inputs

  if result.program.attributes["vertexPos"] != -1:
    var vertexArrayId: GLuint
    glGenVertexArrays(1, vertexArrayId.addr)
    glBindVertexArray(vertexArrayId)
    result.vertexArrayId = vertexArrayId

    var vertexBuffer: GLuint
    glGenBuffers(1, vertexBuffer.addr)
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
    glBufferData(
      GL_ARRAY_BUFFER,
      vertices.len * 5 * 4,
      vertices[0].unsafeAddr,
      GL_STATIC_DRAW
    )
    glVertexAttribPointer(
      result.program.attributes["vertexPos"].GLuint,
      2.GLint,
      cGL_FLOAT,
      GL_FALSE,
      0.GLsizei,
      nil,
    )
    glEnableVertexAttribArray(result.program.attributes["vertexPos"].GLuint)

  if result.program.attributes["vertexUv"] != -1:
    var uvBuffer: GLuint
    glGenBuffers(1, uvBuffer.addr)
    glBindBuffer(GL_ARRAY_BUFFER, uvBuffer)
    glBufferData(
      GL_ARRAY_BUFFER,
      uvData.len * 4 * 2,
      uvData[0].addr,
      GL_STATIC_DRAW
    )
    glVertexAttribPointer(
      result.program.attributes["vertexUv"].GLuint,
      2.GLint,
      cGL_FLOAT,
      GL_FALSE,
      0.GLsizei,
      nil,
    )
    glEnableVertexAttribArray(result.program.attributes["vertexUv"].GLuint)

  if texturePath != "":
    try:
      result.textureId = loadTexture(texturePath).int
      result.texturePath = texturePath
      glActiveTexture(GL_TEXTURE0)
    except PixieError:
      result.textureId = -1

proc display(self: ShaderToy) =
  glViewport(0, 0, self.window.size.x, self.window.size.y)
  glClearColor(0, 0, 0, 1)
  glClear(GL_COLOR_BUFFER_BIT)

  # Keep track of time
  let now = epochTime()

  if self.isPaused:
    self.pausedTime += now - self.startTime - self.elapsedTime

  self.elapsedTime = now - self.startTime

  # Set shader values
  glUseProgram(self.program.programId)

  if self.program.uniforms["iResolution"] != -1:
    let ratio = self.window.size.x.float / self.window.size.y.float
    glUniform3f(
      self.program.uniforms["iResolution"],
      self.window.size.x.GLfloat,
      self.window.size.y.GLfloat,
      ratio.GLfloat,
    )

  if self.program.uniforms["iMouse"] != -1:
    let mpos = self.window.mousePos()
    glUniform2i(self.program.uniforms["iMouse"], mpos.x, mpos.y)

  if self.program.uniforms["iTime"] != -1:
    glUniform1f(
      self.program.uniforms["iTime"],
      float32(self.elapsedTime - self.pausedTime)
    )

  if self.program.uniforms["iChannel0"] != -1 and self.textureId != -1:
    glUniform1i(self.program.uniforms["iChannel0"], 0)
    glBindTexture(GL_TEXTURE_2D, self.textureId.GLuint)

  # Draw
  glDrawArrays(GL_TRIANGLES, 0, 6)
  self.window.swapBuffers()


proc run*(self: ShaderToy) =
  self.window.onButtonPress = proc(button: Button) =
    #echo "onButtonPress ", button
    case button
    of MouseLeft:
      let mpos = self.window.mousePos()
      self.lastClickPos = vec2(mpos.x.float32, mpos.y.float32)
      self.mouseDown = true
    of KeyF11, KeyF:
      self.window.fullscreen = not self.window.fullscreen
    of KeyEscape, KeyQ:
      self.window.closeRequested = true
      return
    of KeySpace:
      self.isPaused = not self.isPaused
      return
    else:
      discard

  self.window.onButtonRelease = proc(button: Button) =
    #echo "onButtonPress ", button
    case button
    of MouseLeft:
      self.mouseDown = false
    else:
      discard

  self.startTime = epochTime()
  self.elapsedTime = 0
  self.pausedTime = 0
  self.mouseDown = false
  self.lastClickPos = vec2(0, 0)

  while not self.window.closeRequested:
    self.display()
    pollEvents()


proc runWithShaderToy*(
    shaderSrc: string,
    title: string,
    width: int = 800,
    height: int = 600,
    texturePath: string = "",
) =
  var shaderToy = newShaderToy(shaderSrc, title, width, height, texturePath)
  shaderToy.run()


proc main() =
  var title: string
  let opts = (
    texture: newStringArg(
      @["-x", "--texture"],
      help = "Texture image file path",
      helpvar = "file"
    ),
    title: newStringArg(
      @["-t", "--title"],
      help = "Window title"
    ),
    width: newIntArg(
      @["-w", "--width"],
      defaultVal = 800,
      help = "Window width in pixels",
      helpvar = "px",
    ),
    height: newIntArg(
      @["-h", "--height"],
      defaultVal = 600,
      help = "Window height in pixels",
      helpvar = "px",
    ),
    verbose: newCountArg(
      @["-v", "--verbose"],
      help = "Verbose output"
    ),
    help: newHelpArg("--help"),
    shader: newStringArg(
      @["<shader>"],
      help = "Fragment shader source path",
      helpvar = "file"
    ),
  )

  opts.parseOrQuit()

  if fileExists(Path(opts.shader.value)):
    if not opts.title.seen:
      title = Path(opts.shader.value).splitFile()[1].string
    else:
      title = opts.title.value
  else:
    quit(&"File not found: {opts.shader.value}")

  runWithShaderToy(
    readFile(opts.shader.value),
    title,
    opts.width.value,
    opts.height.value,
    opts.texture.value,
  )

when isMainModule:
  main()
