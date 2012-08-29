FactoryGirl.define do
  factory :translating do
    association :original, factory: :word
    association :translated, factory: :word

    # make sure words are in different languages (with random sometimes it failed during word's validation)
    before(:create) do |t|
      if (t.original.lang == t.translated.lang)
        t.translated.lang = (Language::AVAILABLE - [t.original.lang]).sample
      end
    end
  end

  factory :translating_with_contexts, parent: :translating do
    association :original_context, factory: :context
    association :translated_context, factory: :context
  end
end