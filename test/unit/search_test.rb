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
    end

    should "downcase query properly" do
      assert_equal "eat ążśźęćńół", @search.query
    end
  end

  context "#new with argument which is not string" do
    setup do
      @query = 123
      @search = Search.new(@query)
    end

    should "try convert query passed as argument to string" do
      assert_equal "123", @search.query
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