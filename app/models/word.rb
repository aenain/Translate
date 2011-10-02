class Word < ActiveRecord::Base
  LANGUAGES = %w{pl en de}

  has_many :translatings, as: :original, dependent: :destroy
  has_many :translations, through: :translatings, source: :translated, source_type: self.name, uniq: true do
    # there was a problem with this association when called methods like below (find_or_create_by...)
    # because it doesn't save translating object (inverse_of doesn't support neither has_many through association nor polymorphic)
    def find_or_create_by_lang_and_name!(lang, name)
      params = { lang: lang, name: name }
      word = Word.first(conditions: params) || Word.create!(params)

      self << word unless self.exists?(word)
    end

    def find_or_create_by_name_and_lang!(name, lang)
      find_or_create_by_lang_and_name!(lang, name)
    end

    def find_or_create_by_lang_and_name(lang, name)
      params = { lang: lang, name: name }
      word = Word.first(conditions: params) || Word.create(params)

      self << word unless self.exists?(word)
    end

    def find_or_create_by_name_and_lang(name, lang)
      find_or_create_by_lang_and_name(lang, name)
    end
  end

  validates :name, presence: :true, uniqueness: { scope: :lang }
  validates :lang, presence: :true

  scope :polish,  where(lang: 'pl')
  scope :english, where(lang: 'en')
  scope :german,  where(lang: 'de')

  scope :none, where(id: 0)

  # Word.by_name('geh') # => ['gehen', geh']
  # Word.by_name('geh', strict: true) # => ['geh']
  scope :by_name, lambda { |name, options = {}| options[:strict] ? where('name = ?', name) : where('name like ?', "%#{name}%") }
  scope :by_highlight, lambda { |highlight, options = {}| options[:strict] ? where('highlight = ?', highlight) : where('highlight like ?', "%#{highlight}%") }
  scope :by_lang, lambda { |lang| where(lang: lang) }

  def self.find_or_build(params = {})
    first(conditions: params) || new(params)
  end

  def name=(name)
    if matcher = name.match(/\[(?<highlight>(.*))\]/)
      self.highlight = matcher[:highlight]
    else
      self.highlight = name
    end

    write_attribute :name, name.gsub(/\[|\]/, '')
  end

  def name(options = {})
    name = read_attribute :name
    name.gsub!(/(#{Regexp.escape(highlight)})/, '[\1]') if options[:highlight] && highlight.present? && name != highlight

    name
  end
end