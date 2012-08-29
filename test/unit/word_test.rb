# encoding: utf-8
require 'test_helper'

class WordTest < ActiveSupport::TestCase
  should have_many(:translatings).dependent(:destroy)
  should have_many(:translations).through(:translatings)
  should have_many(:contexts).through(:translatings)
  should have_many(:translated_contexts).through(:translatings)

  should have_many(:exam_entries).dependent(:destroy)

  should have_db_column(:name).of_type(:string)
  should have_db_column(:lang).of_type(:string)

  should have_db_index(:name)
  should have_db_index([:name, :lang])

  context ".create" do
    context "word without name or language" do
      setup do
        @word = Word.create(name: nil, lang: nil)
      end

      should "not save the word" do
        assert @word.new_record?
      end
    end

    context "word with an empty name" do
      setup do
        @word = Word.create(name: '', lang: 'pl')
      end

      should "not save the word" do
        assert @word.new_record?
      end
    end

    context "two words with the same name and language" do
      setup do
        @existing_word = FactoryGirl.create(:word)
        @identical_word = FactoryGirl.build(:word, name: @existing_word.name, lang: @existing_word.lang)
        @identical_word.save
      end

      should "not save the second word" do
        assert @identical_word.new_record?
      end
    end

    context "two words with the same name but different languages" do
      setup do
        @existing_word = FactoryGirl.create(:word, lang: 'pl')
        @word_with_the_same_name = FactoryGirl.create(:word, name: @existing_word.name, lang: 'de')
        @word_with_the_same_name.save
      end

      should "save the second word" do
        assert !@word_with_the_same_name.new_record?
      end
    end
  end

  context ".by_name" do
    setup do
      @first_word = FactoryGirl.create(:word, name: 'gehen', lang: 'de')
      @second_word = FactoryGirl.create(:word, name: 'gehenna', lang: 'pl')
    end

    should "match by substring when without any options" do
      assert_equal 2, Word.by_name('gehen').count
    end

    should "do exact matching when with option :strict" do
      matched_words = Word.by_name('gehen', strict: true)

      assert_equal 1, matched_words.count
      assert_equal 'gehen', matched_words.first.name
    end
  end
end
