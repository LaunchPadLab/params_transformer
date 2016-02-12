module ParamsTransformer
  class ValueParser
    class Zip < ValueParser
      def parse
        return nil unless input_value.present?
        input_value.try(:to_s)
      end
    end
  end
end
