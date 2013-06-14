class Go
    constructor: (@prefabName) ->

class Component
    constructor: (resources) ->
    initialise: (@go) ->
    update: (timeStep) ->
    toJSON: () ->
    parse: (data) ->
