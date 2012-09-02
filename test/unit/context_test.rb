# encoding: utf-8
require 'test_helper'

class ContextTest < ActiveSupport::TestCase
  should have_one(:translating)
  should have_one(:translation).through(:translating)
  should have_one(:word).through(:translating)

  should have_db_column(:sentence).of_type(:string)

  context ".create" do
    context "context without sentence" do
      setup do
        @context = Context.create(sentence: nil)
      end

      should "not save the context" do
        assert @context.new_record?
      end
    end

    context "context with sentence" do
      setup do
        @context = Context.create(sentence: "It's a simple sentence.")
      end

      should "save the context" do
        assert !@context.new_record?
      end
    end
  end

  context "#parts_to_fill" do
    setup do
      @contexts = {
        none_to_fill: FactoryGirl.create(:context, sentence: "It's simple as hell."),
        one_to_fill: FactoryGirl.create(:context, sentence: "When I was /in/ San Francisco, it was raining outside."),
        more_to_fill: FactoryGirl.create(:context, sentence: "I /know/ it seems to be /funny/."),
      }
    end

    should "extract fragments to fill properly" do
      assert_equal [], @contexts[:none_to_fill].parts_to_fill
      assert_equal ['in'], @contexts[:one_to_fill].parts_to_fill
      assert_equal %w[know funny], @contexts[:more_to_fill].parts_to_fill
    end
  end

  context "#sentence" do
    setup do
      @context = FactoryGirl.create(:context, sentence: "I /know/ it seems to be /funny/.")
    end

    should "return raw value from database if no arguments specified" do
      assert_equal "I /know/ it seems to be /funny/.", @context.sentence
    end

    should "return raw value from database if :raw specified" do
      assert_equal "I /know/ it seems to be /funny/.", @context.sentence(:raw)
    end

    should "return a sentence without fill marks if :clear specified" do
      assert_equal "I know it seems to be funny.", @context.sentence(:clear)
    end
  end
end
