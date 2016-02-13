module Decanter
  module ValueParser

    def self.included(base)
      base.extend(ClassMethods)
      ValueParser.register(base)
    end

    def self.parse(val)
      val
    end
  end
end
