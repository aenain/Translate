require 'test_helper'

class WordTest < ActiveSupport::TestCase
  context "#name=" do
    context "name with highlight" do
      setup do
        @word = Word.new
        @word.name = "rubbish [important] rubbish"
      end

      should "assign name without square brackets" do
        assert_equal "rubbish important rubbish", @word.name
      end

      should "assign to highlight inside of name's square brackets" do
        assert_equal "important", @word.highlight
      end
    end

    context "name without highlight" do
      setup do
        @word = Word.new
        @word.name = "important also important"
      end

      should "assign name as it is" do
        assert_equal "important also important", @word.name
      end

      should "assign to highlight name as it is" do
        assert_equal "important also important", @word.highlight
      end
    end
  end

  context "#name" do
    context "without highlight" do
      setup do
        @word = Word.new
        @word.name = "rubbish [important] rubbish"
      end

      should "return name without square brackets" do
        assert_equal "rubbish important rubbish", @word.name
      end
    end
  end

  context "#name" do
    context "with highlight" do
      setup do
        @word = Word.new
        @word.name = "rubbish [important] rubbish"
      end

      should "return name marking highlight" do
        assert_equal "rubbish [important] rubbish", @word.name(highlight: true)
      end
    end

    context "with blank highlight" do
      setup do
        @word = Word.new
        @word.name = "rubbish [] rubbish"
      end

      should "return name without marking highlight" do
        assert_equal "rubbish  rubbish", @word.name(highlight: true)
      end
    end

    context "with highlight covering whole name" do
      setup do
        @word = Word.new
        @word.name = "important stuff"
      end

      should "return name without marking highlight" do
        assert_equal "important stuff", @word.name(highlight: true)
      end
    end
  end
end
