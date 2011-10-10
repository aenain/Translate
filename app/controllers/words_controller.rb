class WordsController < ApplicationController
  def index
    @search = params[:search]

    @scope = @search.present? ? Search.new(@search).words : Word
    @words = @scope.all(conditions: { lang: Word::LANGUAGES }, order: 'name ASC').group_by(&:lang)
  end

  def show
    @word = Word.find(params[:id])
    @translations = @word.translations.all(conditions: { lang: Word::LANGUAGES }, order: 'name ASC').group_by(&:lang)
  end

  def new
    if params[:word_id].present?
      @word = Word.find_by_id_and_lang(params[:word_id], Settings.language.primary.symbol)
    end

    @word ||= Word.new(lang: Settings.language.primary.symbol)
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

  def autocomplete
    @query = "#{params[:term]} /#{params[:lang]}"
    @words = Search.new(@query).words.all(order: 'name ASC', limit: 10).map { |w| w.name.force_encoding('utf-8') }

    render :json => @words
  end

  def test
  end
end
