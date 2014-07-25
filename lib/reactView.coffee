{ScrollView, $} = require 'atom'
React = require 'react-atom-fork'
debug = require('debug')("debug:atom-sharp:reactView")
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

    props = {
      view: @
      props: @reactProps
    }

    @component = React.renderComponent(@reactComponent(props), @element)
    #TODO: figure out react resize event instead of hooking window?
    $(window).resize () =>
      debug "window resize"
      @component.forceUpdate()
      #@pollComponentDOM()

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
    #@component.forceUpdate()

  show: ->
    super
    @component.forceUpdate()
