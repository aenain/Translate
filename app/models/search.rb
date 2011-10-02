class Search
  attr_accessor :query

  def initialize(query)
    @query = query
  end

  def words
    # TODO! wymyśleć jak rozpoznawać czy wprowadzono: "sich waschen" czy "essen de"
    @search = query.match /^(?<word>[[:alnum:] '\-&]+)(?:\s(?<options>#{lang_options_regexp})?)?$/

    unless @search.nil?
      @word, @original_lang, @translated_lang = @search[:word], @search[:original], @search[:translated]

      if @original_lang.present? && @translated_lang.present? # 'eat en|de' => 'essen'
        @words = Word.by_lang(@original_lang).by_name(@word)

        if @original_lang != @translated_lang # edge case: 'eat en|en' => 'eat'
          @words = Word.by_lang(@translated_lang).joins(:translatings).where(translatings: { translated_type: 'Word', translated_id: @words })
        end
      elsif @original_lang.present? && @translated_lang.nil? # 'eat en|' or 'eat en' => 'eat'
        @words = Word.by_lang(@original_lang).by_name(@word)
      else # 'eat' => 'eat'
        @words = Word.by_name(@word)
      end
    else
      @words = Word.none
    end

    @words
  end

  protected

  def lang_options_regexp
    /\/(?<original>[[:alpha:]]{2})(?:\/(?<translated>[[:alpha:]]{2})?)?/
  end
end
