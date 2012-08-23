module Mockup
  class Base < Object; end

  # defines class in the Mockup namespace with the given body, with the certain accessible attributes or both
  # @param required name Symbol|String - a name of the class
  # @param optional options Hash 
  #   :attributes Array - an array of the attributes' names
  # @param optional definition Proc - a block with class's body (can be merged with attributes list)
  #
  # Examples of usage:
  # Mockup.define_class(:Context) do
  #   attr_accessor :sentence, :lang
  # 
  #   def initialize(options = {})
  #     @sentence = options[:sentence]
  #     @lang = options[:lang]
  #   end
  # end
  # context = Mockup::Context.new(sentence: 'This is a pretty nice sentence.', lang: 'en')
  #
  # Mockup.define_class(:ExtendedContext, attributes: [:sentence, :lang]) do
  #   def sentence_and_lang
  #     [sentence, lang]
  #   end
  # end
  # context = Mockup::ExtendedContext.new(sentence: 'This is a pretty nice sentence.', lang: 'en')
  # context.sentence_and_lang # => ['This is a pretty nice sentence.', 'en']
  # 
  # Mockup.define_class(:Word, attributes: [:name, :lang])
  # word = Mockup::Word.new(name: 'name', lang: 'lang')
  def self.define_class(name, options = {}, &definition)
    klass = if options[:attributes]
      self.define_class_with_attributes(options[:attributes], &definition)
    elsif block_given?
      Class.new(Base, &definition)
    end

    self.const_set(name, klass) if !klass.nil?
  end

  def self.define_class_with_attributes(attributes = [], &further_definition)
    klass = Class.new(Base)

    if !attributes.empty?
      code = <<-CODE
        attr_accessor #{attributes.map { |a| ":#{a}" }.join(', ')}

        def initialize(options = {})
          #{attributes.map do |attribute|
            "@#{attribute} = options[:#{attribute}]"
          end.join(';')}
        end
      CODE

      klass.class_eval(code, __FILE__, __LINE__ + 1)
    end

    klass.class_eval(&further_definition) if block_given?
    klass
  end
end