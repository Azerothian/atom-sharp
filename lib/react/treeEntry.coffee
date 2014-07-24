debug =  require("debug")("atom-sharp:react:treeEntry")
React = require 'react-atom-fork'
{ ol, li, span, div }  = React.DOM
treeEntry = React.createClass {
  getInitialState: ->
    {
      expanded: false
      ignored: false
      selected: false
    }
  render: ->
    cls = "entry"
    cls += " directory list-nested-item" if @props.elements?
    cls += " file" if !@props.elements?
    cls += " expanded" if @state.expanded
    cls += " collapsed" if !@state.expanded
    cls += " status-ignored" if @props.ignored or @state.ignored
    cls += " selected" if @state.selected
    element = undefined
    if @props.elements?
      element = ol { className: "entries list-tree" },
        @props.elements.map (element) ->
          #debug "element", element
          treeEntry(element)
    icon = "icon-file-directory"
    icon = @props.icon if @props.icon?
    li { key: @props.name, className: cls },
      div {
        className: "header list-item"
        onClick: @onHeaderClick
      },
        span { className: "name icon #{icon}" }, @props.name
      element if element?



  onHeaderClick: (e) ->
    debug "onclick", @props
    e.stopPropagation()
    expand = false
    selected = false
    expand = true if @props.elements? and !@state.expanded
    #selected = true if !@state.selected

    if !@props.elements?
      atom.workspaceView.open(@props.fullpath, true)

    @setState {expanded: expand, selected: selected}
}
module.exports = treeEntry
