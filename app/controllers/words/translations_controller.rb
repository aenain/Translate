class Words::TranslationsController < ApplicationController
  before_filter :load_word

  def new
    @lang = params[:lang] || (Language::AVAILABLE - @word.lang).first
  end

  def create
    @word.translations.find_or_create_by_lang_and_name!(params[:translation][:lang], params[:translation][:name])
    redirect_to @word
  end

  def destroy
    @translation = Word.find(params[:id])
    @word.translatings.where(translated_id: @translation.id, translated_type: @translation.class.name).first.destroy

    render :nothing => true
  end

  private

  def load_word
    @word = Word.find(params[:word_id])
  end
end