debug =  require("debug")("atom-sharp:react:tree")
React = require 'react-atom-fork'
treeEntry = require "./treeEntry"
{ ol } = React.DOM
module.exports = React.createClass {
  render: ->
    debug "render tree", @props
    ol { className:"tree-view full-menu list-tree has-collapsable-children focusable-panel" },
      treeEntry @props
}
