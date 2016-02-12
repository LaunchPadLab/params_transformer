module ParamsTransformer
  class ValueParser
    class Phone < ValueParser
      REGEX = /(\d|[.])/

      def parse
        return nil unless input_value.present?
        return input_value if input_value.is_a?(Fixnum)
        input_value.scan(REGEX).join.try(:to_s)
      end
    end
  end
end
