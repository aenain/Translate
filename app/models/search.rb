class Search
  attr_accessor :query

  def initialize(query, options = {})
    @query = query
    @original_lang = options[:lang] || Language::PRIMARY
  end

  def words
    @search = query.match /^(?<word>[[:alnum:] '\-&]+)(?:\s\/(?<translated>[[:alnum:]]+)?)?$/

    unless @search.nil?
      @word, @translated_lang = @search[:word], @search[:translated]

      if @translated_lang.present? # 'eat /de' => 'essen'
        @words = Word.by_lang(@original_lang).by_name(@word)

        if @original_lang != @translated_lang # 'eat /en' => 'eat'
          @words = Word.by_lang(@translated_lang).joins(:translatings).where(translatings: { translated_type: 'Word', translated_id: @words })
        end
      else # 'eat' => 'eat'
        @words = Word.by_lang(@original_lang).by_name(@word)
      end
    else
      @word = Word.none
    end

    @words
  end
end
