# encoding: utf-8
FactoryGirl.define do
  sequence :word_pl do |n|
    words = %w{iść jechać kupić samochód sprzedać klej rower latawiec biurko sierpień kwiat szklanka oglądać}
    words.sample
  end

  sequence :word_de do |n|
    words = %w{gehen fahren kaufen verkaufen sehen gucken riechen schmutzig still leise}
    words.sample
  end

  factory :word do
    lang { Language::AVAILABLE.sample }
    name { FactoryGirl.generate(:"word_#{lang}") }
  end
end