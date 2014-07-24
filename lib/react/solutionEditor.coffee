map = require "coffeemapper"
{$} = require "atom"
React = require 'react-atom-fork'
util = require "util"
path = require "path"
tree = require "./tree"
debug =  require("debug")("debug:atom-sharp:react:solutionEditor")
msbuild = require "../msbuild"
{div, h3, button} = React.DOM

referenceMap = {
  "name": (src, resolve, reject) ->
    debug "referenceMap.name", src
    resolve(src.name)
  "icon": (src, resolve, reject) ->
    debug "referenceMap.icon", src
    resolve("")
}

cleanPath = (str) ->
  if path.sep is '/'
    return str.replace /\\/g, '/'
  return str

projectMap = {
  "name": (src, resolve, reject) ->
    debug "projectMap.name", src
    if src?
      return resolve(src.name)
    return reject()
  "elements": (src, resolve, reject) ->
    debug "projectMap.elements", src
    if !src?
      return reject()
    data = []
    return map(src.References, referenceMap).then (references) ->
      debug "projectMap.elements.serviceReferences", references
      data.push {
        name: "References"
        elements: references
      }
      contentMap = {
        "name": (s, resolve, reject) ->
          debug "contentMap.name", s
          resolve(s.path)
        "fullpath": (s, resolve, reject) ->
          debug "fullpath", s, src.file

          resolve(path.resolve(src.file, "../#{cleanPath(s.path)}"))

        "icon": (src, resolve, reject) ->
          resolve("icon-file-text")
      }


      debug "projectMap.elements.Content start"
      return map(src.Content, contentMap).then (content) ->
        debug "projectMap.elements.Content end", content, src
        data = data.concat content
        debug "projectMap.elements.Compile start"
        return map(src.Compile, contentMap).then (compile) ->
          debug "projectMap.elements.Compile end", compile, src
          data = data.concat compile
          resolve(data)
        , reject
      , reject
    , reject
}

solutionMap = {
  "name": (src, resolve, reject) ->
    resolve(src.name)
  "elements": (src, resolve, reject) ->
    debug "elements", src
    if src.Projects?
      if src.Projects.length > 0
        return map(src.Projects, projectMap).then (projectData) ->
          debug "set elements", projectData
          resolve(projectData)
        , reject
    return reject()

}

#emitter = new EventEmitter()

module.exports = React.createClass {

  statics:
    funcTest: () ->
      debug "funcTest", @

  getInitialState: ->
    {
      treeData: {}
      treeItemsHeight: "100%"
    }
  calcHeight: () ->
    totalHeight = $(".atom-sharp").height()
    buttonHeight = $(".atom-sharp .btn-toolbar").height()
    return totalHeight - buttonHeight

  setHeights: () ->
    newHeight = @calcHeight()
    if newHeight < 0
      debug "new height", newHeight, @state.treeItemsHeight
    else if newHeight != @state.treeItemsHeight
      debug "set bew height"
      @setState({ treeItemsHeight: newHeight })

  shouldComponentUpdate: (nextProps, nextState) ->
    newHeight = @calcHeight()
    debug "newHeight", newHeight, nextState.treeItemsHeight, nextState.treeItemsHeight != newHeight

    return true# nextState.treeItemsHeight != @state.treeItemsHeight

  componentDidUpdate: (prevProps, prevState) ->
    @setHeights()


  onTreeData: (treeData) ->
    debug "setting state", treeData
    @setState({ treeData: treeData })

  componentDidMount: ->
    debug "props", @props.props
    map(@props.props, solutionMap).then (treeData) =>
      json = JSON.parse(JSON.stringify(treeData[0]))
      debug "json", json
      #emitter.emit "treedata", treeData
      @onTreeData(json)
  onCloseClick: ->
    debug "calling destroy"
    @props.view.destroy()

  render: ->
    debug "render", @state.treeData
    div { className: "tool-panel panel-right"},
      #div { className: "tree-view-resize-handle", ref: "resizeHandle" },
      div { className: "btn-toolbar", ref: "toolBar" },
        div { className: "btn-group" },
          #button { type: "button", className: "btn btn-default"}, "Save"
          button { type: "button", className: "btn btn-default", onClick: @onCloseClick }, "Close"
          button { type: "button", className: "btn btn-default", onClick: @build }, "Build"
      div { className: "tree-view-resizer", ref: "treeItems", style: { height: @state.treeItemsHeight } },
        div { className: "tree-view-scroller" },
          tree @state.treeData


  build: () ->
    debug "start build", @props.props.file
    msb = new msbuild({
      src: @props.props.file
      projectConfiguration: 'Debug'
      targets: ["Build"]
      stdout: true
      version: 4.0
      maxCpuCount: 8
    })

    msb.build().then () ->
      debug "build successful"
    , () ->
      debug "build failed"


}
