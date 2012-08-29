# encoding: utf-8
require 'test_helper'

class TranslatingTest < ActiveSupport::TestCase
  should belong_to(:original)
  should belong_to(:translated)

  should belong_to(:original_context).dependent(:destroy)
  should belong_to(:translated_context).dependent(:destroy)

  # TODO! should accept nested attributes

  should have_db_index([:original_id, :translated_id])
  should have_db_index([:original_id, :original_context_id])

  context "reverse translating" do
    setup do
      @original_word = FactoryGirl.create(:word, lang: 'pl')
      @translated_word = FactoryGirl.create(:word, lang: 'de')
      @translating = FactoryGirl.build(:translating, original: @original_word, translated: @translated_word)
    end

    should "create a reverse translating after create" do
      assert_difference('Translating.count', 2) do
        @translating.save!
      end
    end

    should "destroy a reverse translating after destroy" do
      @translating.save!

      assert_difference('Translating.count', -2) do
        @translating.destroy
      end
    end

    context "associations" do
      setup do
        @original_context = FactoryGirl.create(:context)
        @translated_context = FactoryGirl.create(:context)

        @translating = FactoryGirl.create(:translating, original: @original_word,
                                                        translated: @translated_word,
                                                        original_context: @original_context,
                                                        translated_context: @translated_context)
        @reversed = Translating.last
      end

      context "after create" do
        should "handle words' and contexts' ids properly" do
          # words
          assert_equal @translating.original_id, @reversed.translated_id
          assert_equal @translating.translated_id, @reversed.original_id
          # make sure that there are any words at all
          assert_not_nil @translating.original_id
          assert_not_nil @translating.translated_id

          # contexts
          assert_equal @translating.original_context_id, @reversed.translated_context_id
          assert_equal @translating.translated_context_id, @reversed.original_context_id
          # make sure that there are any contexts at all
          assert_not_nil @translating.original_context_id
          assert_not_nil @translating.translated_context_id
        end
      end

      context "#save_and_update_reversed" do
        setup do
          @updated_original_word = FactoryGirl.create(:word, name: 'nowe słowo', lang: 'pl')
          @updated_translated_word = FactoryGirl.create(:word, name: 'neues Wort', lang: 'de')
          @updated_original_context = FactoryGirl.build(:context)
          @updated_translated_context = FactoryGirl.build(:context)

          @translating.original = @updated_original_word
          @translating.translated = @updated_translated_word
          @translating.original_context = @updated_original_context
          @translating.translated_context = @updated_translated_context
          @saved = @translating.save_and_update_reversed

          @translating.reload
          @reversed.reload # should be updated
        end

        should "save the translating" do
          assert !@translating.changed?
        end

        should "return result of save" do
          assert @saved
        end

        should "handle words' and contexts' ids properly" do
          # words
          assert_equal @translating.original_id, @reversed.translated_id
          assert_equal @translating.translated_id, @reversed.original_id

          # contexts
          assert_equal @translating.original_context_id, @reversed.translated_context_id
          assert_equal @translating.translated_context_id, @reversed.original_context_id
        end
      end
    end
  end
end