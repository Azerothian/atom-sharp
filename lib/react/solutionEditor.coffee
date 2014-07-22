
React = require 'react-atom-fork'

require "bootstrap "

{div} = React.DOM

module.exports = React.createClass {

  render: ->
    div {style: { width: "250px" }}

}
