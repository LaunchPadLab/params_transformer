module Decanter
  module ValueParser
    class StringParser < ValueParser
      def self.parse(val)
        val.try(:to_s)
      end
    end
  end
end
