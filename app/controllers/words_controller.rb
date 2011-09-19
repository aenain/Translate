class WordsController < ApplicationController
  def index
    @search = params[:search]

    @scope = @search.present? ? Search.new(@search).words : Word
    @words = @scope.all(order: 'lang DESC, name ASC')
  end

  def show
    @word = Word.find(params[:id])
    @translations = @word.translations.all(order: 'lang DESC, name ASC')
  end

  def new
    @word = Word.new
  end

  def edit
    @word = Word.find(params[:id])
  end

  def create
    @word = Word.first(conditions: params[:word]) || Word.new(params[:word])

    if @word.save!
      %w{en de}.each do |lang|
        next unless params[lang].present?
        @word.translations.create!(name: params[lang], lang: lang)
      end

      redirect_to @word
    else
      render :new
    end
  end

  def update
    @word = Word.find(params[:id])

    if @word.update_attributes(params[:word])
      redirect_to @word
    else
      render :edit
    end
  end

  def destroy
    @word = Word.find(params[:id])
    @word.destroy

    redirect_to words_url
  end

  def autocomplete
    @query = "#{params[:term]} #{params[:lang]}"
    @words = Search.new(@query).words.all(order: 'name ASC', limit: 10).map { |w| w.name.force_encoding('utf-8') }

    render :json => @words
  end

  def test
  end
end
