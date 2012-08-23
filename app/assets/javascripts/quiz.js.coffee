# dependencies: jQuery, jQuery UI Dialog, QuizSummary
root = exports ? this
root.Quiz = class Quiz
  constructor: (options) ->
    @progressBar = options.$progressBar
    @correctnessBar = options.$correctnessBar
    @correctnessMetric = options.$correctnessMetric
    @currentQuestionNumber =options.$currentQuestionNumber
    @allQuestionsCount = options.$questionCount
    
    @questionList = options.$questionList
    @questions = @questionList.children('li')
    @questionSummaryDialog = $("<div></div>").attr('id', 'question-summary-dialog').css('display', 'none').insertAfter(@questionList)

    @statistics =
      answered: 0
      correct: 0
      all: @questions.length

    @allQuestionsCount.text(@statistics.all) if @allQuestionsCount
    @currentIndex = (options.startWith || 1) - 1

    @_bindEvents()
    @skipToQuestion(@currentIndex + 1)


  skipToQuestion: (number) ->
    return if number < 1 || number > @statistics.all
    @currentIndex = number - 1

    $answeredQuestions = @questions.eq(@currentIndex).prevAll('*[data-correct]').addClass('answered hidden')
    @_showQuestionAndFocusAnswer()

    @statistics.answered = $answeredQuestions.length
    @statistics.correct = $answeredQuestions.filter('*[data-correct=true]').length

    @_updateProgress()

  _nextQuestion: ->
    return false if @currentIndex >= @questionCount - 1
    
    @questions.eq(@currentIndex).addClass('answered hidden')
    @currentIndex++
    @_showQuestionAndFocusAnswer()

  _showQuestionAndFocusAnswer: ->
    @questions.eq(@currentIndex).removeClass('hidden').find('input[type=text], *[contenteditable]').eq(0).focus()

  _bindEvents: ->
    self = this
    @questionList.find('form').each ->
      $(this).submit ->
        event.preventDefault()
        self._submit($(this))

    @questionList.find('input[type=text]').bind 'keydown.quiz', (event) ->
      if event.keyCode == 13
        event.preventDefault()
        $(this).trigger('keydown:enter')

    @questionList.find('input[type=text], *[contenteditable]').bind 'keydown:enter', ->
      $(this).parents('form').trigger('submit')

  _submit: ($form) ->
    # TODO! check if there is no need to beforeSend csrf_meta_tags
  
    params = $form.serialize()
    $.extend(params, { last: true }) if @currentIndex == @questionCount - 1 # last question

    # TODO! remove ajax mock-up
    if /mobile/i.test(navigator.userAgent)
      html = """
        <div class="question">
          <h3>angeben</h3>
          <p>Ich habe dich mein Auto angegeben.</p>
          <div class="lang de"></div>
        </div>
        <div class="answer">
          <div class="correct">
            <h3>iść</h3>
            <p>Ja tobie moje auto.</p>
            <div class="lang pl"></div>
          </div>
          <div class="given hidden">
            <h3 class="wrong">isc</h3>
            <p class="wrong">Ja tobie twoje auto.</p>
            <div class="lang pl"></div>
          </div>
        </div>
        <div class="actions">
          <a href="#" class="secondary additional-action" id="toggle-answer">Your Answer</a>
          <a href="#" class="primary next">Next</a>
        </div>
        <script type="text/javascript">
          $(function() {
            $("#toggle-answer").click(function(event) {
              event.preventDefault();
              QuizSummary.toggleAnswer({
                $answer: $(this).parents('.actions').prev(),
                $toggleLink: $(this)
              });
            });
          });
        </script>
        """
    else
      html = """
        <div class="question">
          <h3>angeben</h3>
          <p>Ich habe dich mein Auto angegeben.</p>
          <div class="lang de"></div>
        </div>
        <div class="answer">
          <h3 title='<span class="answer">iść</a>' class="wrong">isc</h3>
          <p title='<span class="answer">Ja tobie twoje auto.</span>'>Ja tobie moje auto.</p>
          <div class="lang pl"></div>
        </div>
        <div class="actions">
          <a href="#" class="primary next">Next</a>
        </div>
        <script type="text/javascript">
          $(function() {
            $('#question-summary-dialog').find('.answer *[title], .question *[title]').tipsy({ opacity: 1, html: true, fade: true, gravity: 'w', offset: 10 });
          });
        </script>
        """

    data = { correct: Math.random() > 0.5, html: html };

    @_markQuestionCorrectness(data.correct)
    @_updateProgress(data.correct)
    @_showQuestionSummary(data)

    return false

    $.post $form.attr('action'), params, (data) =>
      @_markQuestionCorrectness(data.correct)
      @_updateProgress(data.correct)
      @_showQuestionSummary(data)

    return false

  _markQuestionCorrectness: (isCorrect) ->
    answeredQuestion = @questions[@currentIndex]
    answeredQuestion.dataset.correct = isCorrect

  _updateProgress: (isCorrect) ->
    if isCorrect?
      @statistics.correct++ if isCorrect 
      @statistics.answered++

    @progressBar.css('width', (100 * @statistics.answered / @statistics.all) + '%')
    correctShare = 100 * @statistics.correct / @statistics.answered

    if @statistics.answered == 0
      @correctnessBar.css('width', 0)
      @correctnessMetric.addClass('hidden')
    else
      @correctnessBar.css('width', correctShare + '%')
      @correctnessMetric.text(Number(correctShare).toFixed(1) + '%').removeClass('hidden')

    @currentQuestionNumber.text(@statistics.answered + 1)

  _showQuestionSummary: (data) ->
    if data.correct
      @_buildDialog('correct', data.html)
    else
      @_buildDialog('wrong', data.html)

  _buildDialog: (dialogClass, html) ->
    self = this

    @questionSummaryDialog.html(html).dialog
      width: 450,
      resizable: false,
      draggable: false,
      closeText: '',
      dialogClass: dialogClass,
      modal: true,
      open: (event, ui) ->
        $this = $(this)

        if dialogClass == 'correct'
          setTimeout(->
            $this.dialog("close")
          , 1000)
        else
          # trick to make possible closing the dialog with enter
          $this.find('.actions .primary').bind('click', (event) ->
            event.preventDefault()
            $this.dialog("close")
          ).focus()
      ,
      close: (event, ui) ->
        $(this).dialog("destroy")
        self._nextQuestion()