path = require "path"
fs = require "fs"
spawn = require('child_process').spawn
Promise = require "bluebird"

remote = require "remote"
dialog = remote.require "dialog"

debug = require("debug")("debug:atom-sharp:msbuild")
info = require("debug")("info:atom-sharp:msbuild")
fatal = require("debug")("fatal:atom-sharp:msbuild")


defaults = {
  targets: ['Build']
  buildParameters: {}
  failOnError: true
  verbosity: 'normal'
  processor: ''
  nologo: true
  projectConfiguration: "Release"
}
versions = {
  1.0: '1.0.3705',
  1.1: '1.1.4322',
  2.0: '2.0.50727',
  3.5: '3.5',
  4.0: '4.0.30319'
}

#NOTICE: most of this was taken from grunt-msbuild

module.exports = class MsBuild
  constructor: (@options = defaults) ->
    for d of defaults
      if !@options[d]?
        @options[d] = defaults[d]

  build: () =>
    return new Promise (resolve, reject) =>
      cmd = @createCommand()
      args = @createArgs()

      info 'Using cmd:', cmd
      info 'Using args:', args
      command = spawn cmd, args, {}
      command.stdout.on "data", (data) ->
        debug "msbuild", data.toString()

      command.on "close", (code) ->
        if code is 0
          dialog.showMessageBox {
            type: "info"
            title: "Build is complete"
            message: "Your build was successful"
            buttons: ["Ok"]
          }
          resolve()
        else
          dialog.showMessageBox {
            type: "warning"
            title: "Build has failed"
            message: "Build failed with code: #{code}, see the developers console for more information"
            buttons: ["Ok"]
          }
          fatal "MSBuild failed with code: #{code}"
          reject("MSBuild failed with code: #{code}")

  createArgs: () =>
    debug "createArgs"
    args = []
    projectPath = path.normalize "#{@options.src}"

    args.push projectPath
    args.push "/target:" + @options.targets
    args.push "/verbosity:" + @options.verbosity
    args.push "/nologo"  if @options.nologo
    #xbuild does not support maxcpucount
    if @options.maxCpuCount? and !(process.platform is "linux" or process.platform is "darwin")
      debug "Using maxcpucount:", + @options.maxCpuCount
      args.push "/maxcpucount:" + @options.maxCpuCount
    args.push "/property:Configuration=" + @options.projectConfiguration
    args.push "/p:Platform=" + @options.platform  if @options.platform
    for buildArg of @options.buildParameters
      args.push "/property:" + buildArg + "=" + @options.buildParameters[buildArg]
    debug "createCommandArgs", args

    return args

  createCommand: () =>
    debug "createCommand"
    # temp mono xbuild usage for linux / osx - assumes xbuild is in the path, works on my machine...
    return "xbuild" if process.platform is "linux" or process.platform is "darwin"
    version = @options.version
    unless version
      msBuild12x86Path = "C:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe"
      msBuild12x64Path = "C:\\Program Files\\MSBuild\\12.0\\Bin\\MSBuild.exe"
      if fs.existsSync(msBuild12x86Path)
        debug "Using MSBuild at:", msBuild12x86Path
        return msBuild12x86Path
      else if fs.existsSync(msBuild12x64Path)
        debug "Using MSBuild at:", msBuild12x64Path
        return msBuild12x64Path

    version = 4.0 if !version?
    processor = "Framework" + ((if processor is 64 then processor else ""))

    specificVersion = versions[version]
    fatal "Unrecognised .NET framework version \"" + version + "\""  unless specificVersion
    buildExecutablePath = path.join(process.env.WINDIR, "Microsoft.Net", processor, "v" + specificVersion, "MSBuild.exe")
    debug "Using MSBuild at:" + buildExecutablePath
    fatal "Unable to find MSBuild executable" unless fs.existsSync(buildExecutablePath)
    return path.normalize buildExecutablePath
