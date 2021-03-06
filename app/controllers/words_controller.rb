class WordsController < ApplicationController
  RECENT_LIMIT_FOR_GROUPS = (Language::AVAILABLE.count * Word::RECENT_LIMIT * 1.4).ceil

  before_filter :load_word, :only => [:show, :update, :destroy]

  def index
    @words = Word.where(lang: Language::AVAILABLE).order('created_at DESC').limit(RECENT_LIMIT_FOR_GROUPS).group_by(&:lang)
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

  def new
    @word = Word.new(lang: params[:lang] || Language::PRIMARY)
  end

  def create
    @word = Word.find_or_build(params[:word])
    if @word.save # it will not be saved if name is empty
      redirect_to words_path
    else
      render :new
    end
  end

  def show
    @translations = @word.translations.all(conditions: { lang: Language::AVAILABLE }, order: 'name ASC').group_by(&:lang)
    @missing_translation_languages = Language::AVAILABLE - [@word.lang] - @translations.keys
  end

  def update
    @word.update_attributes(params[:word]) # TODO! sensowna obsługa błedów...

    if request.xhr?
      render :nothing => true
    else
      redirect_to word_path
    end
  end

  def destroy
    @word.destroy

    redirect_to words_url
  end

  def autocomplete
    @query = "#{params[:term]} /#{params[:lang]}"
    @words = Search.new(@query).words.all(order: 'name ASC', limit: 3).map { |w| w.name }

    render :json => @words
  end

  private

  def load_word
    @word = Word.find(params[:id])
  end
end
