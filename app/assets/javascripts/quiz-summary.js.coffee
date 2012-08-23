# dependencies: jQuery
root = exports ? this
root.QuizSummary = class QuizSummary
  @TOGGLE_ANSWER_LABELS =
    given: 'Your Answer'
    correct: 'Correct Answer'

  constructor: (options) ->
    @currentIndex = 0

    @questionList = options.$questionList
    @answerBar = options.$answerBar
    @answerIndicators = @answerBar.children('.correct, .wrong')
    @questions = @questionList.children('.question-summary')
    @questionCount = @questions.length

    @prevLink = options.$prevLink
    @nextLink = options.$nextLink

    @toggleAnswerLink = options.$toggleAnswerLink # might be undefined
    @toggled = if @toggleAnswerLink
      @toggleAnswerLink.text() == QuizSummary.TOGGLE_ANSWER_LABELS.correct
    else
      false

    @_bindEvents()

  _bindEvents: ->
    self = this

    @answerBar.children('.correct, .wrong').each (i) ->
      $(this).bind 'click.show-question-summary', (event) ->
        event.preventDefault()
        return false if $(this).hasClass('active')

        self._showQuestionSummary({ index: i })

    @prevLink.bind 'click.show-question-summary', (event) ->
      event.preventDefault()
      self._showQuestionSummary({ prev: true })

    @nextLink.bind 'click.show-question-summary', (event) ->
      event.preventDefault()
      self._showQuestionSummary({ next: true })

    if @toggleAnswerLink
      @toggleAnswerLink.bind 'click.toggle-answer', (event) ->
        event.preventDefault()
        self._toggleAnswer({ current: true })

  _showQuestionSummary: (options) ->
    oldIndex = @currentIndex
    self = this

    if (options.index)
      @currentIndex = options.index
    
    if (options.next)
      @currentIndex += 1
    else if (options.prev)
      @currentIndex -= 1

    return false if (@currentIndex < 0 || @currentIndex > @questionCount - 1)

    if (@currentIndex == 0)
      @_disable(@prevLink)
    else
      @_enable(@prevLink)

    if (@currentIndex == @questionCount - 1)
      @_disable(@nextLink)
    else
      @_enable(@nextLink)

    @_toggleAnswer({ index: oldIndex }) if @toggled
    @answerIndicators.removeClass('active').eq(@currentIndex).addClass('active')
    @questions.addClass('hidden').eq(@currentIndex).removeClass('hidden')

  _enable: ($element) ->
    $element.removeClass('disabled')

  _disable: ($element) ->
    $element.addClass('disabled')

  _toggleAnswer: (options) ->
    index = if options.index then options.index else @currentIndex
    
    QuizSummary.toggleAnswer
      $answer: @questions.eq(index)
      $toggleLink: @toggleAnswerLink
      toggled: @toggled

    @toggled = ! @toggled

  @toggleAnswer: (options) ->
    $answerContainer = options.$answer
    $toggleAnswerLink = options.$toggleLink 
    toggled = if options.toggled? then options.toggled else $answers.filter(':visible').hasClass('given')
    $answers = $answerContainer.find('.correct, .given').toggleClass('hidden')

    if !toggled
      $toggleAnswerLink.text(QuizSummary.TOGGLE_ANSWER_LABELS.correct)
    else
      $toggleAnswerLink.text(QuizSummary.TOGGLE_ANSWER_LABELS.given)


