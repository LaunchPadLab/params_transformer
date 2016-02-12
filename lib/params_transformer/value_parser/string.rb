module ParamsTransformer
  class ValueParser
    class String < ValueParser
      def parse
        input_value.try(:to_s)
      end
    end
  end
end
