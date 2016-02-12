module ParamsTransformer
  class ValueParser
    class Integer < ValueParser
      REGEX = /(\d|[.])/

      def parse
        return nil unless input_value.present?
        return input_value if input_value.is_a?(Fixnum)
        return input_value.to_i if input_value.is_a?(Float)
        input_value.scan(REGEX).join.try(:to_i)
      end
    end
  end
end
