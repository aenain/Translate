class CreateExam < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.integer :score, default: 0
      t.integer :max_score, default: 0
      t.string :lang
      t.string :state

      t.timestamps
    end
  end
end
