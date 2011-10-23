class TranslationsController < ApplicationController
  def new
    @word = Word.new(lang: Language::PRIMARY)
    @translations = {}

    Language::FOREIGN.each do |lang|
      @translations[lang] = ""
    end
  end

  def create
    @word = Word.find_or_build(params[:word])
    @translations = params[:translations]

    if @word.save
      @translations.each do |(lang, name)|
        next unless name.present?
        @word.translations.find_or_create_by_lang_and_name!(lang, name)
      end

      redirect_to @word
    else
      render :new
    end
  end
end