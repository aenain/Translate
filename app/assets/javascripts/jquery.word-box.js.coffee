# closure = ($) ->
class Box
	constructor: (@box, @options) ->
		@lang = @box.attr('lang') || @options.lang

	buildStructure: () ->
		@box.addClass('word-box')

		this.buildWordItem()
		this.buildForm()
		this.buildLanguageMarker()

	buildWordItem: () ->
		@ul = $("<ul></ul>").appendTo(@box)
		@li = $("<li></li>").addClass('clickable').addClass('word').text(@options.word).appendTo(@ul)

		return this

	buildForm: () ->
		@form = $("<form></form>").attr({ action: @options.update.url, method: 'post' }).addClass('hidden').appendTo(@box)

		@methodField = $("<input>").attr({ type: 'hidden', name: '_method' }).val(@options.update.method).appendTo(@form)
		@input = $("<input />").attr({ type: 'text', name: @options.inputName }).addClass('word').appendTo(@form)

		return this

	buildLanguageMarker: () ->
		@languageMarker = $("<div></div>").addClass('lang').appendTo(@box)
		@flag = $("<img />").attr('src', "#{@options.imagesDirectory}/flag-#{@lang}.png").addClass('flag').appendTo(@languageMarker)

		return this

	bindEvents: () ->
		this.bindInputFocus()
		this.bindInputBlur()
		this.bindTogglingItemWithInput()
		this.bindFormSubmit()

		return this

	bindInputFocus: () ->
		@input.bind 'focus.wordBox.word', () -> $(this).parents('.word-box').addClass('focus')
		return this

	bindInputBlur: () ->
		self = this

		@input.bind 'blur.wordBox.word', () ->
      self.box.removeClass('focus')
      self.form.addClass('hidden')
      self.ul.removeClass('hidden')

      self.input.val self.li.text()

		return this

	bindTogglingItemWithInput: () ->
		self = this

		@li.bind 'click.wordBox.word', () ->
			self.ul.addClass('hidden')
			self.form.removeClass('hidden')
			self.input.val self.li.text()

			position = self.input.val().length
			self.input.focus().caret(position, position)

		return this

	bindFormSubmit: () ->
		self = this

		@form.submit () ->
			$.post self.form.attr('action'), self.form.serialize(), (response) ->
				self.form.addClass('hidden')
				self.ul.removeClass('hidden')
				self.li.text(response)

			return false

		return this

$.fn.wordBox = (options) ->
	options = $.extend {}, $.fn.wordBox.defaults, options || {}

	return this.each () ->
		box = new Box $(this), options
		box.buildStructure().bindEvents()
		console.log box

$.fn.wordBox.defaults =
	lang: 'en'
	word: ''

	inputName: 'word'
	imagesDirectory: '/assets'

	update:
		url: '/'
		method: 'put'

# closure jQuery