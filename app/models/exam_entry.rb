class ExamEntry < ActiveRecord::Base
  belongs_to :exam
  belongs_to :question, polymorphic: true

  acts_as_list :scope => :exam

  validates :exam_id, presence: true
  validates :question_id, presence: true
  validates :question_type, presence: true

  scope :awaiting, where(correct: nil)
  scope :wrong, where(correct: false)
  scope :correct, where(correct: true)

  def try_answer(answer)
    raise ArgumentError, "cannot answer question twice!" unless self.correct.nil?

    if possible_answers.by_name(answer).present?
      self.correct = true
      exam.score += self.score
    else
      self.correct = false
    end

    self.save!
    exam.save!

    return correct
  end

  def possible_answers
    question.translations.by_lang(answer_lang)
  end
end