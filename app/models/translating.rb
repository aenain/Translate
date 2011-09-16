class Translating < ActiveRecord::Base
  belongs_to :original, polymorphic: true
  belongs_to :translated, polymorphic: true

  validates :original_id, presence: true, uniqueness: { scope: [:original_type, :translated_id, :translated_type] }
  validates :translated_id, presence: true
  validate :identity_of_original_and_translated_types

  after_create :create_reverse_translating
  after_destroy :remove_reverse_translating

  def identity_of_original_and_translated_types
    return self.original_type == self.translated_type
  end

  def create_reverse_translating
    Translating.create reverse_params
  end

  def remove_reverse_translating
    reverse = Translating.first(conditions: reverse_params)
    reverse.destroy unless reverse.nil?
  end

  private

  def reverse_params
    { original_id: self.translated_id, original_type: self.translated_type,
      translated_id: self.original_id, translated_type: self.original_type }
  end
end