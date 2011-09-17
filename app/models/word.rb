class Word < ActiveRecord::Base
  has_many :translatings, as: :original, dependent: :destroy
  has_many :translations, through: :translatings, source: :translated, source_type: self.name, uniq: true

  validates :name, presence: :true, uniqueness: { scope: :lang }
  validates :lang, presence: :true

  scope :polish,  where(lang: 'pl')
  scope :english, where(lang: 'en')
  scope :german,  where(lang: 'de')

  scope :none, where(id: 0)

  scope :by_name, lambda { |name| where('name like ?', "%#{name}%") }
  scope :by_lang, lambda { |lang| where(lang: lang) }
end