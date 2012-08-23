require 'mockup'

module LanguageBoxHelper
  # checks if the application should handle diacritical marks
  # (some operating systems (like OSX and mobile) handle this on their own)
  def handle_diacritical_marks?
    false # !on_mobile? && !on_osx?
  end

  # builds a language-box container based on a block
  # @param lang Symbol | String
  # @param options Hash
  #   - switch Array | nil - list of all languages it can switch between except the one passed in the lang variable
  #   - class Array | String | nil - css classes for language box (will be appended to the language-box class)
  #   - autocomplete true | false | nil - if false autocomplete-container won't be rendered, otherwise it will be
  #   - for Symbol | String | nil - if specified hidden_field containing lang will be added with the name attribute looking like "#{options[:for]}[lang]" 
  # @param block Proc
  # 
  # Output:
  # %section.language-box.#{options[:class]}
  #   %header
  #     - if options[:switch]
  #       %a.lang.#{lang}{ href: '#language-switch', data-languages: lang and switch }
  #     - else
  #       .lang.#{lang}
  #   .input-container= yield block
  #   - if options[:autocomplete] != false
  #     .autocomplete-container
  def editable_language_box(lang, options = {}, &block)
    autocomplete = options.delete(:autocomplete)
    switch = options.delete(:switch)
    object_name = options.delete(:for)

    content_tag :section, options.merge({ class: prepend_css_class('language-box', options[:class]) }) do
      html = content_tag(:header) do
        if switch.present?
          link_to('', '#language-switch', class: "lang #{lang}", data: { languages: switch.dup.unshift(lang).uniq.join('|') })
        else
          content_tag(:div, '', class: "lang #{lang}")
        end
      end

      html += content_tag(:div, class: 'input-container') do
        nested_html = object_name ? hidden_field_tag("#{object_name}[lang]", lang) : ''.html_safe
        nested_html += capture_haml(&block)
      end

      if autocomplete != false
        html += content_tag(:div, '', class: 'autocomplete-container')
      end

      html
    end
  end

  # depends on diacritical marks' handling responsibility it builds either a container and text_field_tag within or a contenteditable div
  # 1. it should handle diacritical marks
  # .editable-container.#{options[:class]}
  #   %input.editable.#{options[:class]}{type: 'text', value: value, data: options[:data]} # other options that haven't been mentioned here are passed to the input (via text_field_tag)
  # 2. it doesn't should handle diacritical marks
  # .editable.#{options[:class]}{contenteditable: 'true', data: options[:data], data-placeholder: options[:placeholder]} # other options that haven't been mentioned here are passed to the div (via content_tag)
  def editable_field_tag(name, value = nil, options = {})
    data = options.delete(:data) || {}

    if !handle_diacritical_marks?
      container_class = prepend_css_class('editable-container', options[:class])
      options.merge!(class: prepend_css_class('editable', options.delete(:class)))

      content_tag(:div, text_field_tag(name, value, options.merge(data: data)), class: container_class)
    else
      placeholder = options.delete(:placeholder)
      options.merge!(class: prepend_css_class('editable', options.delete(:class)))

      content_tag(:div, value, options.merge(contenteditable: 'true', data: data.merge({ placeholder: placeholder })))
    end
  end

  # builds a container for a list of words in a specified language and yields a block for each word
  # %section.language-box.list.#{options[:class]}
  #   %header
  #     .lang.{ class: lang }
  #   %ul
  #     - words.each do |word|
  #       %li= yield word
  def language_box_word_list(lang, words, options = {})
    content_tag :section, options.merge({ class: 'language-box list' + options[:class].to_s }) do
      html = content_tag(:header) do
        content_tag(:div, '', class: "lang #{lang}")
      end

      html += content_tag(:ul) do
        words.inject("") do |html, word|
          html + content_tag(:li, capture_haml { yield word })
        end.html_safe
      end
    end
  end

  # TODO! temporary mockup, original method takes as argument an array / collection of words (class Word)
  def language_box_word_list_with_mockup(lang, raw_words, options = {}, &block)
    Mockup.define_class(:Word, attributes: [:name, :lang, :contexts_count, :translations_count]) do
      def require_attention?
        contexts_count == 0 || translations_count == 0
      end
    end if !defined?(Mockup::Word)
    
    words = raw_words.collect do |name|
      Mockup::Word.new(name: name, lang: lang, contexts_count: rand(5), translations_count: 5 + rand(10))
    end

    language_box_word_list(lang, words, options, &block)
  end

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