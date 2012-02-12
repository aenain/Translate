class RemovePolymorphicityInAssociationsWithWord < ActiveRecord::Migration
  def up
    change_table :translatings, bulk: true do |t|
      t.remove :original_type
      t.remove :translated_type
    end

    change_table :exam_entries, bulk: true do |t|
      t.remove :question_type
      t.rename :question_id, :word_id
    end
  end

  def down
    change_table :translatings, bulk: true do |t|
      t.string :original_type
      t.string :translated_type
    end

    change_table :exam_entries, bulk: true do |t|
      t.string :question_type
      t.rename :word_id, :question_id
    end
  end
end