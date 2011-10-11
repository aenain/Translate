class CreateExamEntry < ActiveRecord::Migration
  def change
    create_table :exam_entries do |t|
      t.references :exam
      t.references :question, polymorphic: true
      t.string :answer_lang
      t.boolean :correct
      t.integer :position
      t.integer :score, default: 1

      t.timestamps
    end
  end
end
