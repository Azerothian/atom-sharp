map = require "coffeemapper"

React = require 'react-atom-fork'
util = require "util"
path = require "path"
tree = require "./tree"
debug =  require("debug")("atom-sharp:react:solutionEditor")
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
    debug "elemenets", src
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
    }

  onTreeData: (treeData) ->
    debug "onTreeData", @
    #@statics.funcTest()

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
    @props.onDestroy()

  render: ->
    debug "render", @state.treeData
    div { style: { width: "250px" } },
      div { className: "btn-toolbar" },
        div { className: "btn-group" },
          button { type: "button", className: "btn btn-default"}, "Save"
          button { type: "button", className: "btn btn-default", onClick: @onCloseClick }, "Close"
      tree @state.treeData
}
