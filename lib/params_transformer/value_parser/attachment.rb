module ParamsTransformer
  class ValueParser
    class Attachment < ValueParser
      def parse
        return input_value
      end
    end
  end
end
