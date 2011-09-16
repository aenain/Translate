class Translating < ActiveRecord::Base
  belongs_to :original, polymorphic: true
  belongs_to :translated, polymorphic: true

  validates :original_id, presence: true, uniqueness: { scope: [:original_type, :translated_id, :translated_type] }
  validates :translated_id, presence: true
  validate :identity_of_original_and_translated_types

  after_save :create_reverse_translating

  def identity_of_original_and_translated_types
    return self.original_type == self.translated_type
  end

  def create_reverse_translating
    Translating.create original: self.translated, translated: self.original
  end
end