class ExamEntry < ActiveRecord::Base
  MIN_ACCEPTABLE_MATCH_RATIO = 0.85

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

    if answer.present? && match_answer?(answer)
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

  def match_answer?(answer)
    prepare = lambda do |text| text.scan(/[[:alpha:]\-']+/).sort.join(' ') end
    given = prepare.call(answer)

    possible_answers.each do |possible_answer|
      possible = prepare.call(possible_answer.name)
      distance = Text::Levenshtein.distance(given, possible)

      ratio = 1 - distance.to_f / [given.length, possible.length].max
      return true if ratio >= MIN_ACCEPTABLE_MATCH_RATIO
    end

    false
  end
end