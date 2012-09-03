module CacheCounter
  def cache_counter(association)
    method_name = "#{association}_count"
    method = <<-RUBY
      def #{method_name}(recalculate = false)
        if recalculate || @#{method_name}.nil?
          @#{method_name} = #{association}.count
        end

        @#{method_name}
      end
    RUBY

    class_eval(method)
  end
end