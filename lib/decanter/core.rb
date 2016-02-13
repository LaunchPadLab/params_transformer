module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
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
        @context = context
        block.arity.zero? ? instance_eval(&block) : block.call(self)
        @context = nil
      end

      def decant(args)
        context = args[:context] || :default
        context_inputs = inputs[context]
        Hash[
          args.reject { |k,v| k == :context }
              .select { |k,v| context_inputs && context_inputs.has_key?(k) }
              .map    { |k,v| [k, parse(context_inputs[k], v)] }
        ]
      end

      def parse(type, val)
        parser = ObjectSpace.each_object(Class)
                            .detect { |klass| klass      <  ValueParser &&
                                              klass.name == "#{type.to_s.capitalize}Parser" }

        raise NameError.new("unknown value parser: #{type}") unless parser
        parser.parse(val)
      end
    end
  end
end
