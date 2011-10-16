class ChangeExamEntryGivenAnswerCollationToUtf8Bin < ActiveRecord::Migration
  def up
    # polskie znaki wymagają takiej modyfikacji w przeciwnym razie:
    # select exam_entries.* from exam_entries where exam_entries.given_answer like '%ea%'; zwróci np. 'jeść'
    execute %Q{alter table exam_entries modify `given_answer` varchar(255) collate utf8_bin}
  end

  def down
    execute %Q{alter table exam_entries modify `given_answer` varchar(255) collate utf8_unicode_ci}
  end
end

