module ParamsTransformer
  class ValueParser
    class Float < ValueParser
      REGEX = /(\d|[.])/

      def parse
        return input_value unless input_value.present?
        return input_value if ["Float", "Fixnum"].include?(input_value.class.name)
        input_value.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
