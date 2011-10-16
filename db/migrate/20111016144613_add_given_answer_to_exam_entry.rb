class AddGivenAnswerToExamEntry < ActiveRecord::Migration
  def change
    add_column :exam_entries, :given_answer, :string
  end
end
