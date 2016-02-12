module ParamsTransformer
  class ValueParser
    class NilClass < ValueParser
      def parse
        input_value
      end
    end
  end
end
