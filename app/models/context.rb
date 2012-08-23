class Context < ActiveRecord::Base
  FILL_DELIMITER = '/' # character which limits a part in the context to substitute

  has_one :translating, foreign_key: :original_context, inverse_of: :original_context
  has_one :translation, through: :translating, source: :translated_context, class_name: self.name
  has_one :word, through: :translating, source: :original, class_name: Word.name
  has_one :translated_word, through: :translating, source: :translated, class_name: Word.name

  validates :sentence, presence: true
end