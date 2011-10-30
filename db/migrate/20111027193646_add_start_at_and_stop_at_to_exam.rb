class AddStartAtAndStopAtToExam < ActiveRecord::Migration
  def change
    add_column :exams, :start_at, :date
    add_column :exams, :stop_at, :date
  end
end
