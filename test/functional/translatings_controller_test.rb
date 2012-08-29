# encoding: utf-8
require 'test_helper'

class TranslatingsControllerTest < ActionController::TestCase
  context ":new" do
    setup do
      get :new
    end

    should assign_to(:translating)

    should "assign languages properly" do
      assert_equal Language::PRIMARY, assigns(:translating).original.lang
      assert_equal Language::FOREIGN.first, assigns(:translating).translated.lang
    end

    should respond_with(:success)
  end

  context ":create" do
    context "with existing words and contexts' attributes" do
      setup do
        @words_attributes = [{ lang: 'pl', name: 'iść' }, { lang: 'de', name: 'gehen' }]
        @words = @words_attributes.collect { |attributes| FactoryGirl.create(:word, attributes) }

        post :create, translating: {
                        original: @words_attributes[0],
                        translated: @words_attributes[1],
                        original_context_attributes: { id: '', sentence: 'Lubię iść do kina.' },
                        translated_context_attributes: { id: '', sentence: 'Ich mag ins Kino zu gehen.' }
                      }
      end

      should "assign existing words instead of trying to create new ones" do
        assert_equal @words[0], assigns(:translating).original
        assert_equal @words[1], assigns(:translating).translated
      end

      should "create contexts by nested attributes" do
        assert_equal 2, Context.count
        assert_equal 'Lubię iść do kina.', assigns(:translating).original_context.sentence
        assert_equal 'Ich mag ins Kino zu gehen.', assigns(:translating).translated_context.sentence
      end

      should "save translating" do
        assert !assigns(:translating).new_record?
      end


      should "redirect to the original word of the translating" do
        assert_redirected_to(assigns(:translating).original)
      end
    end

    context "with empty words and contexts" do
      setup do
        post :create, translating: {
                        original: { lang: 'pl', name: '' },
                        translated: { lang: 'de', name: '' },
                        original_context_attributes: { sentence: '' },
                        translated_context_attributes: { sentence: '' }
                      }
      end

      should "not save any objects" do
        assert_equal 0, Translating.count
        assert_equal 0, Context.count
        assert_equal 0, Word.count
      end

      should "not validate the translating" do
        assert !assigns(:translating).valid?
      end

      should "renders the form again" do
        assert_template :new
      end
    end

    context "with new words but without contexts" do
      setup do
        post :create, translating: {
                        original: { lang: 'pl', name: 'iść' },
                        translated: { lang: 'de', name: 'gehen' },
                        original_context_attributes: { id: '', sentence: '' },
                        translated_context_attributes: { id: '', sentence: '' }
                      }
      end

      should "save words and translating" do
        assert_equal 2, Translating.count # including a reversed translating
        assert_equal 0, Context.count
        assert_equal 2, Word.count
      end
    end
  end

  context ":update" do
    setup do
      @translating = FactoryGirl.create(:translating)
    end

    context "without contexts" do
      setup do
        @original_word = FactoryGirl.create(:word, name: 'jeździć konno', lang: 'pl')
        @translated_word = FactoryGirl.create(:word, name: 'reiten', lang: 'de')

        put :update, id: @translating.id, translating: {
                                            original: { name: @original_word.name, lang: @original_word.lang },
                                            translated: { name: @translated_word.name, lang: @translated_word.lang }
                                          }
      end

      should "update words" do
        assert_equal @original_word.id, assigns(:translating).original_id
        assert_equal @translated_word.id, assigns(:translating).translated_id
      end

      should "not save contexts" do
        assert_equal 0, Context.count
        assert_nil @translating.original_context_id
        assert_nil @translating.translated_context_id
      end

      should "update reversed translating" do
        assert_equal 1, Translating.where(original_id: @translated_word.id, translated_id: @original_word.id).count
      end

      should "redirect to the original word of the translating" do
        assert_redirected_to(assigns(:translating).original)
      end
    end

    context "with contexts" do
      setup do
        @original_context = FactoryGirl.create(:context)
        @translated_context = FactoryGirl.create(:context)

        @translating.original_context = @original_context
        @translating.translated_context = @translated_context
        @translating.save_and_update_reversed

        put :update, id: @translating.id, translating: {
                                            original: { name: @translating.original.name, lang: @translating.original.lang },
                                            translated: { name: @translating.translated.name, lang: @translating.translated.lang },
                                            original_context_attributes: {
                                              id: @translating.original_context.id,
                                              sentence: 'Updated original sentence.'
                                            },
                                            translated_context_attributes: {
                                              id: @translating.translated_context.id,
                                              sentence: 'Updated translated sentence.'
                                            }
                                          }
      end

      should "update assigned contexts" do
        # original context
        assert_equal @original_context.id, assigns(:translating).original_context_id
        assert_equal 'Updated original sentence.', assigns(:translating).original_context.sentence

        # original context
        assert_equal @translated_context.id, assigns(:translating).translated_context_id
        assert_equal 'Updated translated sentence.', assigns(:translating).translated_context.sentence
      end

      should "update reversed translating" do
        assert_equal 1, Translating.where(original_context_id: @translated_context.id, translated_context_id: @original_context.id).count
      end
    end
  end

  context ":destroy" do
    setup do
      @translating = FactoryGirl.create(:translating_with_contexts)
      delete :destroy, id: @translating.id
    end

    should "destroy translating and it's reversed version" do
      assert_equal 0, Translating.count
    end

    should "destroy related contexts" do
      assert_equal 0, Context.count
    end

    should redirect_to('/words')
  end
end
