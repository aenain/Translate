class ExamEntry < ActiveRecord::Base
  belongs_to :exam
  belongs_to :question, polymorphic: true

  acts_as_list :scope => :exam

  validates :exam_id, presence: true
  validates :question_id, presence: true
  validates :question_type, presence: true

  def try_answer(answer)
    raise ArgumentError, "cannot answer question twice!" unless correct.nil?

    if question.translations.find_by_name(answer)
      self.correct = true
      exam.score += self.score
    else
      self.correct = false
    end

    self.save!
    exam.save!

    return correct
  end
end