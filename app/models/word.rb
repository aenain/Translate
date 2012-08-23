class Word < ActiveRecord::Base
  RECENT_LIMIT = 19

  has_many :exam_entries, dependent: :destroy
  has_many :translatings, foreign_key: 'original_id', dependent: :destroy

  has_many :translations, through: :translatings, source: :translated, class_name: self.name, uniq: true do
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

  has_many :contexts, through: :translatings, source: :original_context, class_name: Context.name
  has_many :translated_contexts, through: :translatings, source: :translated_context, class_name: Context.name

  has_many :reverse_translatings, foreign_key: :translated_id, inverse_of: :translated
  has_many :reverse_translations, through: :reverse_translatings, source: :original, class_name: self.name, uniq: true

  validates :name, presence: :true, uniqueness: { scope: [:lang] }
  validates :lang, presence: :true

  scope :polish,  where(lang: 'pl')
  scope :english, where(lang: 'en')
  scope :german,  where(lang: 'de')

  scope :none, where(id: 0)

  # Word.by_name('geh') # => ['gehen', geh']
  # Word.by_name('geh', strict: true) # => ['geh']
  scope :by_name, lambda { |name, options = {}| options[:strict] ? where('name = ?', name) : where('name like ?', "%#{name}%") }

  # scope :by_name, lambda { |name, options = {}|
  #   if options[:strict]
  #     where(name: name).order('name ASC')
  #   else
  #     usage = options.delete(:usage)
  #     usage = "search" unless %w{quiz search autocomplete}.include?(usage)
  #
  #     Word.send(:"by_name_for_#{usage}", name, options)
  #   end
  # }
  #
  # scope :by_name_for_quiz, lambda { |name, options = {}|
  #   like_condition = 'words.name like :like_name and char_length(words.name) <= 1.18 * :length'
  #   scope_options = { like_name: "%#{name}%", length: name.length }
  #
  #   scope = where(like_condition, scope_options).order('name ASC')
  #
  #   if scope.count.zero?
  #     levenstein_condition = "ratio_as_words_array(words.name, :exact_name) >= 0.85 and char_length(words.name) <= 1.18 * :length"
  #     scope = where("(#{like_condition}) or (#{levenstein_condition})", scope_options.merge(exact_name: name)).order('name ASC')
  #   end
  #
  #   scope
  # }
  #
  # scope :by_name_for_search, lambda { |name, options = {}|
  #   like_condition = 'name like :like_name'
  #   scope_options = { like_name: "%#{name}%" }
  #
  #   scope = where(like_condition, scope_options).order('name ASC')
  #
  #   if name.length >= 2 and scope.count.zero?
  #     levenstein_condition = "ratio_as_words_array(words.name, :exact_name) >= 0.7"
  #     scope = where("(#{like_condition}) or (#{levenstein_condition})", scope_options.merge(exact_name: name)).order('name ASC')
  #   end
  #
  #   scope
  # }
  #
  # scope :by_name_for_autocomplete, lambda { |name, options = {}|
  #   like_condition = 'name like :like_name'
  #   scope_options = { like_name: "%#{name}%" }
  #
  #   scope = where(like_condition, scope_options).order('name ASC')
  #
  #   if scope.count < options[:limit].to_i
  #     levenstein_condition = "ratio_as_words_array(name, :exact_name) >= 0.7"
  #     scope = where("(#{like_condition}) or (#{levenstein_condition})", scope_options.merge(exact_name: name)).order('name ASC').limit(options[:limit])
  #   end
  #
  #   scope
  # }

  scope :by_lang, lambda { |*lang| where(lang: lang) }
  scope :by_creation_date, lambda { |date_range|
    start_at = date_range.first.beginning_of_day
    stop_at = date_range.last.end_of_day

    where(created_at: start_at..stop_at)
  }

  def self.find_or_build(params = {})
    first(conditions: params) || new(params)
  end

  def build_translation(params = {})
    translating = self.translatings.build
    translating.build_translated(params)
  end

  def for_js
    { id: id, name: name, lang: lang }
  end
end