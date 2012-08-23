# DEPENDENCIES: jQuery && hashchange event
#
# DESCRIPTION: allows simple "routing" via generated menu or based only on an url. After matching the url, corresponding element gets the class 'active' and other "routable" elements get the class 'hidden', so you have to define the class 'hidden' prevents elements from being visible. It's very useful when you want to have all of your markup (even with mockups) in one html document but also have opportunity to switch between views.
#
# PARAMS:
#   * routableElementSelector String - selector for jQuery used for fetching all "routable" elements
#   * routes Hash - keys are explicitly matched against window.location's hash (preceded by #!), values can be in 2 formats:
#     a. explicit selector of an "routable" element to be matched (it's used to filter all elements in jQuery)
#     b. hash containing two properties: selector (it suits against previous point), callback (function called after routing)
#
# EXAMPLE OF USAGE:
# new Routing(".routable-element",
#   'word': '#word', # matches URL: HOST/PATH/#!word to an element which can be filtered by '#word' selector from the routable elements
#   'exam': # matches URL: HOST/PATH/#!exam
#     selector: '#quiz', # to an element with the quiz id (to be more specific: '#quiz.routable-element')
#     callback: ->
#       console.log 'Quiz Loaded!'
# ).buildNavigation().dispatch()
#
root = exports ? this
root.Routing = class Routing
  constructor: (@routableElementSelector, @routes) ->

  buildNavigation: ->
    $nav = $("<nav></nav>").addClass('mockup-navigation')
    $ul = $("<ul></ul>").appendTo($nav)

    for route of @routes
      if @routes.hasOwnProperty(route)
        $a = $("<a></a>").attr('href', window.location.pathname + "#!" + route).text(route.replace(/-/, ' '))
        $("<li></li>").attr('data-route', route).append($a).appendTo($ul)

    $nav.appendTo($(document.body))
    return this

  dispatch: ->
    $(window).bind 'hashchange.dispatch-routes', =>
      hash = window.location.hash

      if /^#![\d\w-_]+/.test(hash)
        route = hash.match(/^#!(.+)$/)[1]
            
        $(@routableElementSelector).addClass('hidden').filter(@routes[route].selector || @routes[route]).removeClass('hidden')
        $(".mockup-navigation li").removeClass('active').filter('[data-route=' + route + ']').addClass('active')

        @routes[route].callback() if typeof @routes[route].callback == "function"

    $(window).trigger('hashchange.dispatch-routes')