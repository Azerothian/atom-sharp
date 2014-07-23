# {ScrollView} = require 'atom'
ReactView = require './reactView'
React = require "react-atom-fork"
debug = require("debug")("atom-sharp:solutionView")

solutionEditor = require "./react/solutionEditor"

module.exports =
class solutionView extends ReactView
  constructor: (@reactProps) ->
    debug "set component"
    @reactComponent = solutionEditor
    super
  @content: ->
    @div {class: "atom-sharp"}

  initialize: (serializeState) ->

  serialize: ->
    {}
