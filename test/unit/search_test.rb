# encoding: utf-8
require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  context "#new" do
    setup do
      @query = "eat ĄŻŚŹĘĆŃÓŁ"
      @search = Search.new(@query)
    end

    should "only save the query as instance variable" do
      assert_equal [:@query], @search.instance_variables
      assert_equal @query, @search.query
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
