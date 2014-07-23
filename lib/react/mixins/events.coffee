EventEmitter = require("events").EventEmitter


module.exports = {
  componentWillMount: ->
    @eventRefs = []

    if @getEvents?
      @eventRefs = @getEvents().map (ev) =>
        {
          name: ev.name
          id: mesg.on ev.name, ev.func
        }



  componentWillUnmount: ->
    for ev in @eventRefs
      console.log "[mesgmixin] #{ev.name}, #{ev.id}"
      mesg.off ev.id

}
