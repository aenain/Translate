module LanguageBoxHelper
  def word_box(word_or_words, options = {}, &block)
    words = Array(word_or_words)

    content_tag :div, options.merge({ class: options[:class].to_s + ' word-box' }) do
      html = word_box_header_by_lang(words.first.lang)

      html += content_tag :ul do
        words.reduce('') do |nested_html, word|
          nested_html << capture_haml(word, &block)
        end.html_safe
      end
    end
  end

  private

  def word_box_header_by_lang(lang)
    content_tag :div, class: 'lang' do
      image_tag "flag-#{lang}.png", class: 'flag'
    end
  end
end