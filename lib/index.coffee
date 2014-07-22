remote = require "remote"

dialog = remote.require "dialog"

vsproj = require "vsproj"
require("debug").enable("*")
debug = require("debug")("atom-sharp:index")


solutionView = require "./solutionView"

module.exports =
  atomSharpView: null

  activate: (state) ->
    atom.workspaceView.command "atom-sharp:open:solution", @openSolution

  openSolution: () ->
    dialog.showOpenDialog title: 'Open', properties: ['multiSelections', 'createDirectory', 'openFile'], (pathsToOpen) =>
      debug "paths #{pathsToOpen}"
      if pathsToOpen.length > 0
        path = pathsToOpen[0]
        debug "paths #{path}"
        vsproj.openSolution(path).then (solution) ->
          debug "creating view?"
          view = new solutionView solution
          debug "append to the right"
          #atom.workspace.getActivePane().addItem(view)
          atom.workspaceView.appendToRight(view)
          debug "solution open", solution

  deactivate: ->
    @atomSharpView.destroy()

  serialize: ->
    atomSharpViewState: @atomSharpView.serialize()
