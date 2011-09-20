closure = ($) ->
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

	# convention: instance variables are $-wrapped elements (except @options and @lang)
	class Box
		constructor: (@box, @options) ->
			@lang = @box.attr('lang') || @options.lang
			console.log this

		buildStructure: ->
			@box.addClass('language-box').identify('language-box')
			this.buildMainBar()
			this.buildTextarea()

		buildMainBar: ->
			@mainBar = $("<div></div>").addClass('main-bar').appendTo(@box)
			this.buildSpecialLetterList()
			this.buildLanguageMarker()

		buildSpecialLetterList: ->
			@specialLetterList = $("<ul></ul>").addClass('special-letters').appendTo(@mainBar)
			self = this

			$.each this.mergeAllLettersIntoOneList(), (index, letter) ->
				$letter = $("<li></li>").addClass('clickable').text(letter).appendTo(self.specialLetterList)

			return this

		mergeAllLettersIntoOneList: ->
			@letters = $.merge [], @options.specialLetter.list[@lang]?.small || []
			capitalLetters = $.merge [], @options.specialLetter.list[@lang]?.capital || []

			return $.merge(@letters, capitalLetters)

		buildLanguageMarker: ->
			@languageMarker = $("<div></div>").addClass('lang').appendTo(@mainBar)
			@flag = $("<img />").addClass('flag').attr('src', "#{@options.imagesDirectory}/flag-#{@lang}.png").attr('alt', "flag-#{@lang}").appendTo(@languageMarker)
			return this

		buildTextarea: ->
			@textarea = $("<textarea></textarea>").appendTo(@box)
			return this

		setUpData: ->
			# $.data requires a specific DOM object as the first argument (not $-wrapped)
			$.data @textarea[0], 'languageBox', { sourceUrl: @options.sourceUrl, lang: @lang }
			return this

		bindEvents: ->
			this.bindSpecialLetterEvents()
			this.bindTextareaEvents()

		bindSpecialLetterEvents: ->
			self = this

			@specialLetterList.children('li').bind 'click.languageBox.specialLetter', () ->
				# now this points to clicked element (li)
				replaceSelectionWithText { element: self.textarea, text: $(this).text() }, () ->
				  # autocomplete search has to be triggered (changing a value of the input via js doesn't automatically fires up autocomplete)
				  self.textarea.autocomplete('search')

			return this

		bindTextareaEvents: ->
			this.bindFocusEvents()
			this.bindKeyCombinations()

		bindFocusEvents: ->
			@textarea.bind 'focus.languageBox.textarea blur.languageBox.textarea', () -> $(this).parent().toggleClass('focus')
			return this

		bindKeyCombinations: ->
			this.prepareKeyCombinations()
			self = this

			for combination in @combinations
				@textarea.bind 'keydown.languageBox.combinations', combination, (event) ->
					event.preventDefault()

					nth = Number event.data.match(/\d+$/)[0]
					specialLetter = self.options.specialLetter

					nth += (specialLetter.list[self.lang]?.small || []).length if specialLetter.switcher.test(event.data)
					$letter = self.textarea.siblings('.main-bar').find(".special-letters li:nth-child(#{String(nth)})")

					if $letter?
						$letter.trigger('click.languageBox.specialLetter')
						specialLetter.clickCallback($letter) if specialLetter.clickCallback?

			return this

		prepareKeyCombinations: ->
			formats = @options.combinationFormats
			@combinations = []

			for format in [formats.small, formats.capital]
				for number in [1..9]
					@combinations.push format.replace('NUMBER', number)

		setUpAutocomplete: ->
			@textarea.autocomplete $.extend({}, @options.autocomplete, { appendTo: '#' + @box.attr('id') })
			return this

	$.fn.languageBox = (options) ->
		options = $.extend {}, $.fn.languageBox.defaults, options || {}

		return this.each () ->
			box = new Box $(this), options
			box.buildStructure().setUpData().bindEvents().setUpAutocomplete()
 
	$.fn.languageBox.defaults =
		combinationFormats:
			small: 'alt+NUMBER'
			capital: 'alt+shift+NUMBER'

		lang: 'en'

		specialLetter:
			switcher: /shift/ # difference between combinationFormat for small and capital letter as regexp
			list:
				en:
					small: []
					capital: []
				de:
					small: ['ä','ö','ü','ß']
					capital: ['Ä','Ö','Ü']
				pl:
					small: ['ą','ć','ę','ł','ń','ó','ś','ź','ż']
					capital: ['Ą','Ć','Ę','Ł','Ń','Ó','Ś','Ź','Ż']

			clickCallback: ($letter) ->
				$letter.addClass('focus').delay(150).queue () ->
					$letter.removeClass('focus')
					$letter.dequeue()

		sourceUrl: '/'
		imagesDirectory: '/assets'

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