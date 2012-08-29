class Translating < ActiveRecord::Base
  belongs_to :original, class_name: Word.name
  belongs_to :translated, class_name: Word.name
  belongs_to :original_context, class_name: Context.name, dependent: :destroy
  belongs_to :translated_context, class_name: Context.name, dependent: :destroy

  accepts_nested_attributes_for :original_context, :translated_context, :reject_if => lambda { |attributes| attributes[:sentence].blank? }

  validates :original_id, presence: true, uniqueness: { scope: [:translated_id] }
  validates :translated_id, presence: true
  validate  :validate_contexts

  after_create :create_reverse_translating
  after_destroy :remove_reverse_translating

  def create_reverse_translating
    Translating.create(reverse_params)
  end

  def save_and_update_reversed
    if self.new_record?
      raise StandardError, "after_create callback does the same. Use save instead."
    end

    reverse = Translating.where(original_id: self.translated_id_was,
                                translated_id: self.original_id_was,
                                original_context_id: self.translated_context_id_was,
                                translated_context_id: self.original_context_id_was).first

    saved = self.save
    reverse.update_attributes(reverse_params) if !reverse.nil? && saved

    return saved
  end

  def remove_reverse_translating
    reverse = Translating.first(conditions: reverse_params)
    reverse.destroy unless reverse.nil?
  end

  def build_missing_contexts
    self.original_context ||= Context.new
    self.translated_context ||= Context.new
  end

  def lang(association)
    if [:original, :translated].include?(association)
      self.send(association).lang
    else
      Language::PRIMARY
    end
  end

  def to_s(options = {})
    delimiter = options[:delimiter] || "\n"

    if options[:context] && original_context?
      [original.name, original_context.sentence].join(delimiter)
    else
      original.name
    end
  end

  def build_reverse
    reverse = Translating.new

    reverse.original = translated
    reverse.translated = original
    reverse.original_context = translated_context
    reverse.translated_context = original_context

    reverse
  end

  private

  def reverse_params
    { original_id: self.translated_id, original_context_id: self.translated_context_id,
      translated_id: self.original_id, translated_context_id: self.original_context_id }
  end

  # two situations are acceptible: both contexts are given or none
  def validate_contexts
    (original_context_id != nil) == (translated_context_id != nil)
  end
end