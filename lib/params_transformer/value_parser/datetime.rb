module ParamsTransformer
  class ValueParser
    class DateTime < ValueParser
      attr_reader :input_format

      def after_init(args)
        @input_format = args[:input_format] || "%m/%d/%Y"
      end

      def parse
        return input_value unless input_value.present?
        return input_value if input_value.is_a?(DateTime)
        ::Date.strptime(input_value, input_format)
      end
    end
  end
end
