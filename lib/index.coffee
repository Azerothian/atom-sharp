
{$} = require "atom"
remote = require "remote"
paths = require "path"

dialog = remote.require "dialog"

d = require("debug")
#d.enable("atom-sharp*")
vsproj = require "vsproj"
debug = d("atom-sharp:index")


solutionView = require "./solutionView"

module.exports =
  atomSharpView: null

  activate: (state) ->
    atom.workspaceView.command "atom-sharp:open:solution:tree", @openSolutionFromTreeView()
    atom.workspaceView.command "atom-sharp:open:solution:browse", @browseSolution()


  openSln: (path) ->
    debug "paths #{path}", paths.extname(path)
    if paths.extname(path) != ".sln"
      return
    vsproj.openSolution(path).then (solution) ->
      debug "creating view?"
      view = new solutionView solution
      debug "append to the right"
      #atom.workspace.getActivePane().addItem(view)
      atom.workspaceView.appendToRight(view)
      debug "solution open", solution

  browseSolution: () ->
    return (e, source) =>
      openDialogProp = {
        title: 'Open'
        properties: ['multiSelections', 'createDirectory', 'openFile']
      }
      dialog.showOpenDialog openDialogProp, (pathsToOpen) =>
        debug "paths #{pathsToOpen}"
        if pathsToOpen?
          path = pathsToOpen[0]
          @openSln(path)




  openSolutionFromTreeView: () ->
    return (e, source) =>
      found = $(".tree-view .selected > span")
      if found.length > 0
        debug "found", found[0].attributes["data-path"].value
        path = found[0].attributes["data-path"].value
        if path?
          if paths.extname(path) is ".sln"
            return @openSln(path)
      return @browseSolution()




  deactivate: ->
    @atomSharpView.destroy()

  serialize: ->
    atomSharpViewState: @atomSharpView.serialize()
