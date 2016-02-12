module ParamsTransformer
  class ValueParser
    class HasOne < ValueParser
      include ParamsTransformer::ValueParser::Relationship

      # should return a pattern like...
      # {
      #   document_attributes: {
      #     name: "Name of doc",
      #     date: #datetime_object
      #   }
      # }
      def parse
        return input_value unless input_value.present?
        transformer.new(input_value).transform
      end
    end
  end
end
