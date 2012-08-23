class AddOriginalAndTranslatedContextsToTranslating < ActiveRecord::Migration
  def change
    change_table :translatings do |t|
      t.references :original_context
      t.references :translated_context
    end

    add_index :translatings, :original_context_id
    add_index :translatings, :translated_context_id
  end
end
