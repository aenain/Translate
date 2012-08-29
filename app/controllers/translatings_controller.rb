class TranslatingsController < ApplicationController
  def new
    @translating = Translating.new
    @translating.original = Word.new(lang: Language::PRIMARY)
    @translating.translated = Word.new(lang: Language::FOREIGN.first)
    @translating.build_missing_contexts
  end

  def create
    @translating = Translating.new
    @translating.original = Word.find_or_create(params[:translating].delete(:original))
    @translating.translated = Word.find_or_create(params[:translating].delete(:translated))
    @translating.attributes = params[:translating]

    if @translating.save
      redirect_to @translating.original.reload
    else
      @translating.build_missing_contexts
      render :new
    end
  end

  def update
    @translating = Translating.find(params[:id])
    @translating.original = Word.find_or_create(params[:translating].delete(:original))
    @translating.translated = Word.find_or_create(params[:translating].delete(:translated))
    @translating.attributes = params[:translating]
    
    if @translating.save_and_update_reversed
      redirect_to @translating.original.reload
    else
      @translating.build_missing_contexts
      render :edit
    end
  end

  def destroy
    @translating = Translating.find(params[:id])
    @translating.destroy

    redirect_to words_path  
  end
end