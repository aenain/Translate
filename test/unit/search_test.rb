# encoding: utf-8
require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  context "#new" do
    setup do
      @query = "eat ĄŻŚŹĘĆŃÓŁ"
      @search = Search.new(@query)
    end

    should "not save the translated_lang as instance variable" do
      assert_equal [:@query, :@original_lang], @search.instance_variables
      assert_equal @query, @search.query
    end

    should "use primary language if not specified" do
      assert_equal Language::PRIMARY, @search.instance_variable_get(:@original_lang)
    end
  end

  context "#query=" do
    setup do
      @query = 'eat'
      @search = Search.new(@query)
    end

    should "have writeable attribute for @query" do
      assert_nothing_raised NoMethodError do @search.query = 'more' end
    end
  end
end
