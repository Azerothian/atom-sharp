{ScrollView} = require 'atom'
React = require 'react-atom-fork'
debug = require('debug')("atom-sharp:reactView")
module.exports =
class ReactView extends ScrollView
  # Tear down any state and detach
  destroy: ->
    @detach()

  afterAttach: (onDom) ->
    return unless onDom
    return if @attached
    debug "is attached?"
    @attached = true
    @component = React.renderComponent(@reactComponent(@reactProps), @element)

  beforeRemove: ->
    React.unmountComponentAtNode(@element)
    @attached = false

  focus: ->
    if @component?
      @component.onFocus()
    else
      @focusOnAttach = true

  hide: ->
    super
    @pollComponentDOM()

  show: ->
    super
    @pollComponentDOM()

  pollComponentDOM: ->
    return unless @component?
    valueToRestore = @component.performSyncUpdates
    @component.performSyncUpdates = true
    @component.pollDOM()
    @component.performSyncUpdates = valueToRestore
