class Translating < ActiveRecord::Base
  belongs_to :original
  belongs_to :translated

  validates :original_id, presence: true, uniqueness: { scope: [:translated_id] }
  validates :translated_id, presence: true

  after_create :create_reverse_translating
  after_destroy :remove_reverse_translating

  def create_reverse_translating
    Translating.create(reverse_params)
  end

  def remove_reverse_translating
    reverse = Translating.first(conditions: reverse_params)
    reverse.destroy unless reverse.nil?
  end

  private

  def reverse_params
    { original_id: self.translated_id,
      translated_id: self.original_id }
  end
end