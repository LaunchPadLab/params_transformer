module ParamsTransformer
  class ValueParser
    class HasMany < ValueParser
      include ParamsTransformer::ValueParser::Relationship

      # should return a pattern like...
      # {
      #   loads_attributes: {
      #     "0" => {
      #       pays_fuel_surcharge: true,
      #       pickup_datetime: #datetime_object
      #     }
      #   }
      # }
      def parse
        return input_value unless input_value.present?
        parse_hash if input_value.is_a?(Hash)
        parse_array if input_value.is_a?(Array)
      end

      def parse_hash
        hash = {}
        input_value.each do |index, obj_hash|
          object_hash = transformer.new(obj_hash).transform
          hash[index] = object_hash
        end
        hash
      end

      def parse_array
        hash = {}
        input_value.each_with_index do |obj_hash, index|
          object_hash = transformer.new(obj_hash).transform
          hash[index] = object_hash
        end
        hash
      end
    end
  end
end
