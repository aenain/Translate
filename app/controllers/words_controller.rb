class WordsController < ApplicationController
  def index
    @words = Word.where(lang: Language::AVAILABLE).order('created_at DESC').group_by(&:lang)
  end

  def search
    @query = params[:query]
    @lang = params[:lang]

    @results = Search.new(@query, lang: @lang).words.where(lang: Language::AVAILABLE)

    if @results.length == 1
      redirect_to @results.first
    else
      @words = @results.order('name ASC').group_by(&:lang)
    end
  end

  def show
    @word = Word.find(params[:id])
    @translations = @word.translations.all(conditions: { lang: Language::AVAILABLE }, order: 'name ASC').group_by(&:lang)
  end

  def new
    if params[:word_id].present?
      @word = Word.find_by_id_and_lang(params[:word_id], Language::PRIMARY)
    end

    @word ||= Word.new(lang: Language::PRIMARY)
  end

  def create
    @word = Word.find_or_build(params[:word])

    if @word.save!
      params[:translations].each do |(lang, name)|
        next unless name.present?
        @word.translations.find_or_create_by_lang_and_name!(lang, name)
      end

      redirect_to @word
    else
      render :new
    end
  end

  def update
    @word = Word.find(params[:id])
    @word.update_attributes(params[:word]) # TODO! sensowna obsługa błedów...

    if request.xhr?
      render :nothing => true
    else
      redirect_to word_path
    end
  end

  def destroy
    @word = Word.find(params[:id])
    @word.destroy

    redirect_to words_url
  end

  def new_translation
    @word = Word.find(params[:id])
    @lang = params[:lang] || (Language::AVAILABLE - @word.lang).first
  end

  def create_translation
    @word = Word.find(params[:id])
    lang, name = params[:translation][:lang], params[:translation][:name]

    @word.translations.find_or_create_by_lang_and_name!(lang, name)
    redirect_to @word
  end

  def remove_translation
    @word = Word.find(params[:id])
    @translation = Word.find(params[:translation_id])

    @word.translatings.where(translated_id: @translation.id, translated_type: @translation.class.name).first.destroy

    render :nothing => true
  end

  def autocomplete
    @query = "#{params[:term]} /#{params[:lang]}"
    @words = Search.new(@query).words.all(order: 'name ASC', limit: 3).map { |w| w.name }

    render :json => @words
  end

  def test
  end
end
