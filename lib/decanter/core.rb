module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
      Decanter.register(base)
    end

    module ClassMethods

      def inputs
        @inputs ||= {}
      end

      def input(name, type, **options)
        context = options[:context] || @context || :default
        inputs[context] = {} unless inputs.has_key? context
        inputs[context][name] = type
      end

      def with_context(context, &block)
        raise NameError.new('no context argument provided to with_context') unless context

        @context = context
        block.arity.zero? ? instance_eval(&block) : block.call(self)
        @context = nil
      end

      def decant(args={}, context=nil)
        context_inputs = inputs[context || :default]
        Hash[
          args.select { |k,v| context_inputs && context_inputs.has_key?(k) }
              .map    { |k,v| [k, parse(context_inputs[k], v)] }
        ]
      end

      def parse(type, val)
        ValueParser.value_parser_for(type).parse(val)
      end
    end
  end
end
