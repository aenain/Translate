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
			@text = @box.attr('text') || @options.text

			@useAutocomplete = (typeof @options.autocomplete == 'object' and @options.autocomplete)
			@allowLanguageChanges = (typeof @options.languages == 'object' && @options.languages)

		buildLayout: ->
			this.addBoxAttributes()

			switch @options.layout
				when 'extended' then this.buildExtendedStructure()
				when 'compact' then this.buildCompactStructure()
				else $.error('Given type of layout is not supported.')

			return this

		addBoxAttributes: ->
			@box.addClass('language-box').identify('language-box').css(this.boxDimensions())

		boxDimensions: ->
		  dimensions =
		    height: @options.height || @options.layoutDimensions[@options.layout].height
		    width: @options.width || @options.layoutDimensions[@options.layout].width

		  return dimensions

		buildExtendedStructure: ->
		  this.buildVisibleMainBar()
		  this.buildInputField()
		  this.prepareLanguageMarker().appendTo(@mainBar)

		buildCompactStructure: ->
		  this.buildHiddenMainBar()
		  this.buildInputField()
		  this.prepareLanguageMarker().appendTo(@box)

		buildVisibleMainBar: ->
			this.buildMainBar()
			this.buildSpecialLetterList()

			return this

		buildHiddenMainBar: ->
		  this.buildMainBar()
		  @mainBar.css { 'display': 'none' }

		  this.buildSpecialLetterList()
		  return this

		buildMainBar: ->
		  @mainBar = $("<div></div>").addClass('main-bar').appendTo(@box)

		buildSpecialLetterList: ->
			@specialLetterList = $("<ul></ul>").addClass('special-letters').appendTo(@mainBar)
			self = this

			$.each this.mergeAllLettersIntoOneList(), (index, letter) ->
				self.buildSpecialLetterListItemByLetter(letter)

			return this

		mergeAllLettersIntoOneList: ->
			this.mergeAllLettersIntoOneListByLang(@lang)

		mergeAllLettersIntoOneListByLang: (lang) ->
			@letters = $.merge [], @options.specialLetter.list[lang]?.small || []
			capitalLetters = $.merge [], @options.specialLetter.list[lang]?.capital || []

			return $.merge(@letters, capitalLetters)

		buildSpecialLetterListItemByLetter: (letter) ->
			$letter = $("<li></li>").addClass('clickable').text(letter).appendTo(@specialLetterList)

		prepareLanguageMarker: ->
			@languageMarker = $("<div></div>").addClass('lang')
			@flag = $("<img />").addClass('flag').attr this.languageMarkerFlagAttributesByLang(@lang)

			if @allowLanguageChanges
				@languageSwitcher = $("<a></a>").addClass('lang-link').attr({ href: '#translateLanguageSwitch', title: 'Change Language' }).appendTo(@languageMarker)
				@flag.appendTo @languageSwitcher
			else
				@flag.appendTo @languageMarker

			return @languageMarker

		languageMarkerFlagAttributesByLang: (lang) ->
			{ src: "#{@options.imagesDirectory}/flag-#{lang}.png", alt: "flag-#{lang}" }

		buildInputField: ->
		  name = @options.inputFieldNameFormat.replace('LANG', @lang)
		  cssParams = this.inputFieldCssParams()

		  if @options.layout == 'extended'
		  	@inputField = $("<textarea></textarea>")
		  else
		    @inputField = $("<input />").attr('type', 'text')

		  @inputField.val(@text).attr('name', name).css(cssParams)
		  @inputField.attr('placeholder', @options.placeholder) if @options.placeholder?
		  @inputField.appendTo(@box)

		  return this

		inputFieldCssParams: ->
		  boxHeight = parseFloat this.boxDimensions().height
		  boxWidth = parseFloat this.boxDimensions().width

		  switch @options.layout
		    when 'extended'
		      height = boxHeight - 55 # TODO! don't hardcode this values...
		      width = boxWidth - 6
		    when 'compact'
		      height = boxHeight - 6
		      width = boxWidth - 41

		  height = height.toString() + 'px'
		  width = width.toString() + 'px'

		  params =
		    minWidth: width
		    width: width
		    maxWidth: width
		    minHeight: height
		    height: height
		    maxHeight: height

		  return params

		setUpData: ->
			data = { lang: @lang }

			if @useAutocomplete
				$.extend data, { sourceUrl: @options.sourceUrl, termMapper: @options.termMapper }
			if @allowLanguageChanges
				$.extend data, { languages: @options.languages }

			# $.data requires a specific DOM object as the first argument (not $-wrapped)
			$.data @inputField[0], 'languageBox', data

			return this

		bindEvents: ->
			this.bindSpecialLetterEvents()
			this.bindInputFieldEvents()
			this.bindLanguageSwitch() if @allowLanguageChanges
			return this

		bindSpecialLetterEvents: ->
			self = this

			$("##{@box.attr('id')} ul.special-letters li.clickable").live 'click.languageBox.specialLetter', () ->
				# now this points to clicked element (li)
				replaceSelectionWithText { element: self.inputField, text: $(this).text() }, () ->
					if @useAutocomplete
				  	# autocomplete search has to be triggered (changing a value of the input via js doesn't automatically fires up autocomplete)
				  	self.inputField.autocomplete('search')

			return this

		bindInputFieldEvents: ->
			this.bindFocusEvents()
			this.bindKeyCombinations()

		bindFocusEvents: ->
			@inputField.bind 'focus.languageBox.inputField', () -> $(this).parent().addClass('focus')
			@inputField.bind 'blur.languageBox.inputField', () -> $(this).parent().removeClass('focus')

			@inputField.bind 'focus.languageBox.setPosition', () ->
				position = $(this).val().length
				$(this).caret(position, position)

			return this

		bindKeyCombinations: ->
			this.prepareKeyCombinations()
			self = this

			@inputField.unbind 'keydown.languageBox.combinations'

			for combination in @combinations
				@inputField.bind 'keydown.languageBox.combinations', combination, (event) ->
					event.preventDefault()

					nth = Number event.data.match(/\d+$/)[0]
					specialLetter = self.options.specialLetter

					nth += (specialLetter.list[self.lang]?.small || []).length if specialLetter.switcher.test(event.data)
					$letter = self.inputField.siblings('.main-bar').find(".special-letters li:nth-child(#{String(nth)})")

					if $letter?
						$letter.trigger('click.languageBox.specialLetter')
						specialLetter.clickCallback($letter) if specialLetter.clickCallback?

			return this

		prepareKeyCombinations: ->
			formats = @options.combinationFormats
			letters = @options.specialLetter.list[@lang]

			@combinations = []

			for size in ['small', 'capital']
				format = formats[size]
				lettersBySize = letters[size]

				if lettersBySize?
					for number in [1..lettersBySize.length]
						@combinations.push format.replace('NUMBER', number)

		bindLanguageSwitch: ->
			self = this

			@flag.bind 'click.switchToNextLanguage', (event) ->
				event.preventDefault()
				self.switchToNextLanguage()
				self.bindKeyCombinations()
				self.inputField.focus()

			return this

		switchToNextLanguage: () ->
			data = $.data @inputField[0], 'languageBox'
			self = this

			if data.languages? && data.languages.length > 1
				@specialLetterList.children('li').remove()

				@lang = data.lang = this.nextLanguage(data.lang, data.languages)
				@box.attr({ 'lang': @lang }) if @box.attr('lang')?
				@flag.attr this.languageMarkerFlagAttributesByLang(data.lang)

				$.each this.mergeAllLettersIntoOneListByLang(data.lang), (index, letter) ->
					self.buildSpecialLetterListItemByLetter(letter)

				$.data @inputField[0], 'languageBox', data
				self.options.languageChangeCallback(@lang) if self.options.languageChangeCallback?

			return this

		nextLanguage: (lang, languages) ->
			index = $.inArray lang, languages

			if index < languages.length - 1
				index += 1
			else
				index = 0

			languages[index]

		setUpAutocomplete: ->
			if @useAutocomplete
				@inputField.autocomplete $.extend({}, @options.autocomplete, { appendTo: '#' + @box.attr('id') })

			return this

	# Dependencies:
	# 1. jQuery Caret: http://code.google.com/p/jcaret
	# 2. jQuery Identify: http://stackoverflow.com/questions/470772/does-jquery-have-an-equivalent-to-prototypes-element-identify#answer-2821241
	# 3. jQuery Hotkeys: https://github.com/jeresig/jquery.hotkeys
	# 4. jQuery UI Autocomplete: http://jqueryui.com/demos/autocomplete
	$.fn.languageBox = (options) ->
		options = $.extend {}, $.fn.languageBox.defaults, options || {}

		return this.each () ->
			box = new Box $(this), options
			box.buildLayout().bindEvents().setUpData().setUpAutocomplete()
 
	$.fn.languageBox.defaults =
		combinationFormats:
			small: 'alt+NUMBER'
			capital: 'alt+shift+NUMBER'

		text: ''

		lang: 'en'
		languages: null
		languageChangeCallback: null

		inputFieldNameFormat: 'translations[LANG]'
		placeholder: null

		# these parameters take precedence (if have values...) before those specified for certain layouts
		width: null
		height: null

		layout: 'extended' # extended | compact
    # extended - with place for special letters and autocomplete
    # compact - without special letters, with input[type=text] instead of textarea and with autocomplete (we suggest to turn it off)

		layoutDimensions:
		  extended:
		    width: '550px'
		    height: '108px'
		  compact:
		    width: '550px'
		    height: '21px'

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
				inputField = this.element[0]
				data = $.data inputField, 'languageBox'
				term = $(inputField).val()

				if data.sourceUrl.length > 0
					$.getJSON data.sourceUrl, { term: term, lang: data.lang }, (data) ->
						response data
				else
					[]

closure jQuery