# DEPENDENCIES: jQuery
#
# DESCRIPTION: manages processes which can be split into steps. Finds elements with 'step' class into container (passed to constructor) and based on class 'current' figures out which step is current. Binds switching between steps to elements with one of the classes 'prev-step', 'next-step'. Switching steps means triggering 'step:out' event on the current step, then transfering the class and triggering 'step:in' event on the new current step.
#
# PARAMS:
#   @param container - a jQuery container for the whole process (should have '.step' elements)
#
root = exports ? this
root.Step = class Step
  constructor: (@container) ->
    @steps = @container.find('.step')
    @stepsCount = @steps.length;
    @currentIndex = @steps.filter('.current').prevAll('.step').length

    @_bindEvents()
    @step(@currentIndex)

  _bindEvents: ->
    @steps.each (i, step) =>
      if (i + 1 < @stepsCount)
        $(step).find('.next-step').click (event) =>
          event.preventDefault()
          @step(i + 1)
      
      if i > 0
        $(step).find('.prev-step').click (event) =>
          event.preventDefault()
          @step(i - 1)

  step: (index) ->
    @steps.eq(@currentIndex).removeClass('current').trigger('step:out')
    @currentIndex = index
    @steps.eq(@currentIndex).addClass('current').trigger('step:in')