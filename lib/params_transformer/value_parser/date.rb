module ParamsTransformer
  class ValueParser
    class Date < ValueParser

      attr_reader :parse_format

      def after_init(args)
        @parse_format = args[:parse_format] || "%m/%d/%Y"
      end

      def parse
        return input_value unless input_value.present?
        return input_value if input_value.is_a?(Date)
        ::Date.strptime(input_value, parse_format)
      end

    end
  end
end
