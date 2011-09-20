closure = ($) ->
	# event handlers
	bindTextareaKeyCombinations = ($textarea, combinationFormats, callback) ->
		combinations = []

    for i in [1..9]
      combinations.push combinationFormats.small.replace('NUMBER', i)
      combinations.push combinationFormats.capital.replace('NUMBER', i)

    for combination in combinations
      $textarea.bind 'keydown.languageBox.combinations', combination, (event) ->
        event.preventDefault()
        $self = $(this)

        nth = Number event.data.match(/\d+$/)[0]
        nth = 2 * (nth - 1) + 1
        nth += 1 if /shift/.test(event.data)

        $letter = $self.siblings('.main-bar').find('.special-letters li:nth-child(' + String(nth) + ')')

        if $letter?
          $letter.trigger('click.languageBox.specialLetter')
          callback($letter) if callback?

	clickLanguageBoxSpecialLetter = (element) ->
    $textarea = $(element).parents('.language-box').children('textarea')

    replaceSelectionWithText { element: $textarea, text: $(element).text() }, () ->
      # autocomplete search has to be triggered (changing a value of the input via js doesn't automatically fires up autocomplete)
      $textarea.autocomplete('search')

	# generic functions
	replaceSelectionWithText = (options, callback) ->
    $element = options.element
    caret = $element.caret()

    $element.val caret.replace(options.text)

    # caret.end is index of last char in selection (or last char in input)
    # caret.text is text of selection or empty string
    position = max(caret.end - caret.text.length, 0) + options.text.length
    # move cursor to proper position (right after replacement)
    $element.caret(position, position)

    callback($element) if callback?

  max = (a, b) ->
    if a >= b then a else b

	# very specific functions
	initBox = ($box, options) ->
		$box.addClass('language-box').identify('language-box')
    lang = $box.attr('lang')

    $mainTab = $("<div></div>").addClass('main-bar').appendTo($box)
    $specialLettersList = $("<ul></ul>").addClass('special-letters').appendTo($mainTab)

    $.each (options.specialLetters[lang] || []), (letter) ->
      $("<li></li>").addClass('clickable').text(letter).appendTo($specialLettersList)

    $lang = $("<div></div>").addClass('lang').appendTo($mainTab)
    $flag = $("<img />").addClass('flag').attr('src', options.imagesDirectory + "flag-" + lang + ".png").attr('alt', "flag-" + lang).appendTo($lang)

    $textarea = $("<textarea></textarea>").appendTo($box)

		# setting up data
    $.data $textarea[0], 'languageBox', { sourceUrl: options.sourceUrl, lang: lang }

    # binding events
    $specialLettersList.children('li').bind 'click.languageBox.specialLetter', () -> clickLanguageBoxSpecialLetter(this)
    $textarea.bind 'focus.languageBox.textarea blur.languageBox.textarea', () -> $(this).parent().toggleClass 'focus'

    bindTextareaKeyCombinations $textarea, options.combinationFormats, options.specialLetterClickCallback

    # setting up autocomplete
    $textarea.autocomplete $.extend({}, options, { appendTo: '#' + $box.attr('id') })

	$.fn.languageBox = (options) ->
		options = $.extend {}, $.fn.languageBox.defaults, options || {}

		return this.each () ->
			$box = $(this)
			initBox $box, options

	$.fn.languageBox.defaults =
		combinationFormats:
		  small: 'alt+NUMBER'
		  capital: 'alt+shift+NUMBER'
		
		specialLetters:
			en: []
			de: ['ä','Ä','ö','Ö','ü','Ü','ß']
			pl: ['ą','Ą','ć','Ć','ę','Ę','ł','Ł','ń','Ń','ó','Ó','ś','Ś','ź','Ź','ż','Ż']

		sourceUrl: '/'
		imagesDirectory: '/assets/'

	  specialLetterClickCallback: ($letter) ->
	    $letter.addClass('focus').delay(150).queue () ->
	      $letter.removeClass('focus')
	      $letter.dequeue()

		autocomplete:
	    minLength: 2

      open: (event, ui) ->
        $(this).addClass('with-prompts')

        menu = $(this).next(".ui-autocomplete.ui-menu")
        menu.removeAttr("style")

      close: (event, ui) ->
        $(this).removeClass('with-prompts')

      focus: (event, ui) ->
        menu = $(this).next(".ui-autocomplete.ui-menu")

        menu.children(".focus").removeClass("focus")
        menu.children(".ui-menu-item:has(.ui-state-hover)").addClass("focus")

      source: (request, response) ->
        textarea = this.element[0]
        data = $.data textarea, 'languageBox'

        $.getJSON data.sourceUrl, { term: $(textarea).val(), lang: data.lang }, (data) ->
          response data

closure jQuery