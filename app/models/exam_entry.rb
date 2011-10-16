class ExamEntry < ActiveRecord::Base
  belongs_to :exam
  belongs_to :question, polymorphic: true

  acts_as_list :scope => :exam

  validates :exam_id, presence: true
  validates :question_id, presence: true
  validates :question_type, presence: true

  scope :awaiting, where(given_answer: nil)
  scope :wrong, where(correct: false)
  scope :correct, where(correct: true)

  def try_answer(answer)
    raise ArgumentError, "cannot answer question twice!" unless self.given_answer.nil?
    self.given_answer = answer

    if answer.present? && possible_answers.by_name(answer).present?
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