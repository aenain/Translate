(function($) {
	function LanguageBox(options) {
		
	}

	// Dependencies: jquery, jquery.hotkeys, jquery.autocomplete, jquery.caret
	LanguageBox.prototype.checkDependencies = function() {
		if (typeof $.hotkeys == "undefined") {
			$.error('jQuery.hotkeys is missing. See more: https://github.com/jeresig/jquery.hotkeys');
			return false;
		}

		if (typeof $().autocomplete == "undefined") {
			$.error('jQuery.autocomplete is missing. See more: http://jqueryui.com/demos/autocomplete');
			return false;
		}

		if (typeof $().caret == "undefined") {
			$.error('jQuery.caret is missing. See more: http://code.google.com/p/jcaret');
			return false;
		}

		return true;
	}

	$.fn.languageBox = function(options) {
		return this.each(function() {
			var $this = $(this);
		});
	};

	$.fn.languageBox.supportedLanguages = ['en', 'de', 'pl'];
	$.fn.languageBox.specialLetters = {
		'en': { small: [], capital: [] },

		'de': {
			small: 	 ['ä', 'ö', 'ü', 'ß'],
			capital: ['Ä', 'Ö', 'Ü', 'ß']
		},

		'pl': {
			small: 	 ['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż'],
			capital: ['A', 'Ć', 'Ę', 'Ł', 'Ń', 'Ó', 'Ś', 'Ź', 'Ż']
		}
	}
})(jQuery);