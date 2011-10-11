class Exam < ActiveRecord::Base
  LENGTH = 20 # how many questions

  has_many :entries, class_name: 'ExamEntry', order: 'position', dependent: :destroy

  validates :lang, presence: true, inclusion: { in: Word::LANGUAGES }

  after_create :create_entries

  def create_entries
    words = self.class.select_words_by_languages(languages)

    words.each do |word|
      answer_lang = (languages - [word.lang]).first || Settings.language.primary.symbol
      entries.create(question: word, answer_lang: answer_lang)
    end

    self.max_score = entries.inject(0) { |total, entry| total + entry.score }
    self.save

    entries
  end

  protected

  def languages
    [Settings.language.primary.symbol, lang]
  end

  def self.select_words_by_languages(languages = [])
    # silence assumption that +word+ has translation in +answer_lang+.
    word_ids = Word.where(lang: languages).all(select: 'id').map(&:id).shuffle.first(LENGTH)
    words = Word.where(id: word_ids).all
  end
end