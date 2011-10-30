class Exam < ActiveRecord::Base
  LENGTH = 20 # how many questions

  has_many :entries, class_name: 'ExamEntry', order: 'position', dependent: :destroy

  validates :lang, presence: true, inclusion: { in: Language::AVAILABLE }
  validate :words_presence_in_given_range

  after_create :create_entries

  def create_entries
    words = self.class.select_words(languages: languages, creation_dates: start_at..stop_at)

    words.each do |word|
      answer_lang = (languages - [word.lang]).first || Language::PRIMARY
      entries.create(question: word, answer_lang: answer_lang)
    end

    self.max_score = entries.inject(0) { |total, entry| total + entry.score }
    self.save

    entries
  end

  def words_presence_in_given_range
    return true # TODO! implement this.
  end

  def self.estimate_words_count(options = {})
    languages = options[:languages]
    creation_dates = options[:creation_dates]

    Word.by_lang(languages).by_creation_date(creation_dates).count
  end

  protected

  def languages
    [Language::PRIMARY, lang]
  end

  def self.select_words(options = {})
    languages = options[:languages]
    creation_dates = options[:creation_dates]

    word_ids = Word.by_lang(languages).by_creation_date(creation_dates).all(select: 'id').map(&:id).shuffle
    words = []

    while words.count < LENGTH and word_ids.present?
      word = Word.find(word_ids.shift)
      translations = word.translations.by_lang(languages)

      unless translations.empty?
        if translations.count == 1
          translation = translations.first

          if translation.translations.count < 2
            word_ids -= [translation.id]
          end
        end

        words << word
        word_ids.shuffle!
      end
    end

    words
  end

end