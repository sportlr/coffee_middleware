class CoffeeMiddleware.System.Base
  # list event to subscribe to, and in the event context try to reinitialize this view
  @subscribeTo: []
  # selector that corresponds to this view
  @selector:    null
  # binding method, options are: bindOne, bindMany, bindCollection
  @bindMethod:  'bindMany'
  # default scope, where to look for
  @scope:       document
  # use caching, that means one dom element will get bound only once to a class
  @caching:     true

  # Bind many elements, each to its own class
  @bindMany: (selector, context = @scope) ->
    collection = []
    instance = @

    if $(selector, context).length > 0
      $(selector, context).each (index, element) =>
        el = $(element)
        if @caching
          if @addToCache(instance.hashCode(), element)
            collection.push(new instance(el))
        else
          collection.push(new instance(el))

    collection

  # Force only single element
  @bindOne: (selector, context = @scope) ->
    if $(selector, context).length > 0
      el = $(selector, context)
      if @caching
        if @addToCache(@.hashCode(), el[0])
          new @(el)
      else
        new @(el)

  # Bind a collection of elements
  @bindCollection: (selector, context = @scope) ->
    if $(selector, context).length > 0
      el = $(selector, context)
      if @caching
        if @addToCache(@.hashCode(), el[0])
          new @(el)
      else
        new @(el)

  # Initalize this componet: Will apply this class to the @selector, using the bindMethod selected
  @init: ->
    if @selector
      @[@bindMethod].apply(@, [@selector])
      @handleSubscriptions()

  # add listeners to the @subscribeTo events, to reinitalize
  @handleSubscriptions: ->
    for event in @subscribeTo
      ($ @scope).on event, (e) =>
        parent = $(e.target).parent()
        context = if parent.length > 0 then parent else e.target
        @[@bindMethod].apply(@, [@selector, context])


  @addToCache: (name, element) ->
    unless CoffeeMiddleware.Cache[name]
      CoffeeMiddleware.Cache[name] = []
    unless @cacheContains(name, element)
      CoffeeMiddleware.Cache[name].push element
      return true
    false

  @forceCache: (name, element) ->
    index = CoffeeMiddleware.Cache[name].indexOf(element)
    if index == -1
      @addToCache(name, element)
    else
      CoffeeMiddleware.Cache[name][index] = element

  @cacheContains: (name, element) ->
    element in CoffeeMiddleware.Cache[name]

  @hashCode: ->
    val = @.prototype.constructor.toString()
    hash = 0

    if val.length == 0 then return hash

    for i in [0...val.length]
      char = val.charCodeAt(i)
      hash = ((hash<<5)-hash)+char
      hash |= 0

    hash

  @clearCache: ->
    for key, val of CoffeeMiddleware.Cache
      delete CoffeeMiddleware.Cache[key]


  reBind: =>
    @.constructor(@.container)

  constructor: (@container) ->