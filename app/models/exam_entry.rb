class ExamEntry < ActiveRecord::Base
  belongs_to :exam
  belongs_to :question, polymorphic: true

  acts_as_list :scope => :exam

  validates :exam_id, presence: true
  validates :question_id, presence: true
  validates :question_type, presence: true

  scope :awaiting, where(correct: nil)

  def try_answer(answer)
    raise ArgumentError, "cannot answer question twice!" unless self.correct.nil?

    if question.translations.by_name(answer).by_lang(answer_lang).present?
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