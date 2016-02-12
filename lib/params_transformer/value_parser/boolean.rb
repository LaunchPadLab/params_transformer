module ParamsTransformer
  class ValueParser
    class Boolean < ValueParser
      def parse
        return nil if input_value.nil?
        return nil if input_value == "on"
        return true if input_value == "1"
        return true if input_value == true
        return true if input_value == "true"
        return false
      end
    end
  end
end
