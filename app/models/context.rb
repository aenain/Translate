class Context < ActiveRecord::Base
  FILL_DELIMITER = '/' # character which limits a part in the context to substitute

  has_one :translating, foreign_key: :original_context_id, inverse_of: :original_context
  has_one :translation, through: :translating, source: :translated_context, class_name: self.name
  has_one :word, through: :translating, source: :original, class_name: Word.name
  has_one :translated_word, through: :translating, source: :translated, class_name: Word.name

  validates :sentence, presence: true, length: { minimum: 5 }

  # returns as array of strings fragments of sentence which are expected to be filled out in quiz
  def parts_to_fill
    parts = []
    sentence.scan(/(?:\/)([^\/]+)(?:\/)/) { |group| parts << group[0] }
    parts
  end

  # returns sentence in the certain formats:
  # :raw (def.) - exactly what's in database
  # :clear - remove fill markers and returns clear sentence
  def sentence(format = :raw)
    raw_sentence = read_attribute(:sentence)

    case format
      when :raw then raw_sentence
      when :clear then raw_sentence.gsub(FILL_DELIMITER, '')
    end
  end
end