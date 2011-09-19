module WordsHelper
  def words_for_javascript(options = {})
    lang = options[:lang]

    words = lang.nil? ? Word.all : Word.by_lang(lang.to_s)
    array_or_string_for_javascript words.map { |w| w.name.force_encoding('utf-8') }
  end
end
