module ParamsTransformer
  class ValueParser
    module Relationship
      attr_reader :transformer

      def after_init(args = {})
        @transformer = args[:transformer]
        raise "An associated transformer class is required for #{self.class.name} input" unless @transformer.present?
      end
    end
  end
end
