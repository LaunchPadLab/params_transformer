module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
      Decanter.register(base)
    end

    module ClassMethods

      def associations
        @associations ||= {}
      end

      def inputs
        @inputs ||= {}
      end

      def input(name, type, **options)
        set_input options, {
          name:    name,
          options: options.reject { |k| k == :context },
          type:    type
        }
      end

      def set_input(options, input_cfg)
        set_for_context options, input_cfg, inputs
      end

      def input_for(name, context)
        (inputs[context || :default] || {})[name]
      end

      def has_many(name, **options)
        set_association options, {
          key:     options[:key] || "#{name}_attributes",
          name:    name,
          options: options.reject { |k| k == :context },
          type:    :has_many
        }
      end

      def has_one(name, **options)
        set_association options, {
          key:     options[:key] || "#{name}_attributes",
          name:    name,
          options: options.reject { |k| k == :context },
          type:    :has_one
        }
      end

      def has_many_for(name, context)
        (associations[context || :default] || {})
          .select { |key, assoc| assoc[:type] == :has_many }[name]
      end

      def has_one_for(name, context)
        (associations[context || :default] || {})
          .select { |key, assoc| assoc[:type] == :has_one }[name]
      end

      def set_association(options, assoc)
        set_for_context options, assoc, associations
      end

      def set_for_context(options, arg, hash)
        context = options[:context] || @context || :default
        hash[context] = {} unless hash.has_key? context
        hash[context][arg[:name]] = arg
      end

      def with_context(context, &block)
        raise NameError.new('no context argument provided to with_context') unless context

        @context = context
        block.arity.zero? ? instance_eval(&block) : block.call(self)
        @context = nil
      end

      def decant(args={}, context=nil)
        Hash[
          args.map { |name, value| handle_arg(name, value, context) }.compact
        ]
      end

      def handle_arg(name, value, context)
        case
        when input_cfg = input_for(name, context)
          [name, parse(input_cfg[:type], value)]
        when assoc = has_one_for(name, context)
          [name, decanter_for(assoc).decant(value, context)]
        when assoc = has_many_for(name, context)
          decanter = decanter_for(assoc)
          [name, value.map { |val| decanter.decant(val, context) }]
        else
          context ? nil : [name, value]
        end
      end

      def parse(type, val)
        ValueParser.value_parser_for(type).parse(val)
      end
    end
  end
end
