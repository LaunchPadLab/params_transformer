module ParamsTransformer
  class Base
    attr_reader :params, :inputs
    attr_accessor :inputs

    def initialize(args)
      @params = Rails.version[0].to_i > 4 ? args.to_h.with_indifferent_access : HashWithIndifferentAccess.new(args)
      @inputs = set_inputs
      after_init(@params)
    end

    def transform
      hash = {}
      inputs.each do |input|
        value = instance_variable_get("@#{input.variable_name}")

        # only set values to nil when they are intended to be nil
        next if value.nil? && (input.association? || params.keys.exclude?(input.name.to_s))

        hash[input.variable_name] = value
      end
      hash
    end

    def self.input(name, type = nil, options = {})
      @@input_definitions ||= {}
      array = @@input_definitions[self.name].present? ? @@input_definitions[self.name] : []
      array << [name, type, options]
      @@input_definitions[self.name] = array
    end

    def self.input_definitions
      @@input_definitions
    end

    private

      def set_inputs
        setter = ParamsTransformer::DirectoryParser.new(current_class_name: self.class.name)
        all_inputs = []
        ParamsTransformer::Base.input_definitions.each do |class_name, form_inputs|
          next unless setter.relevant_classes.include?(class_name)
          form_inputs.each do |form_input|
            all_inputs << set_input(form_input)
          end
        end
        all_inputs
      end

      def set_input(form_input)
        name = form_input[0]
        type = form_input[1]
        options = form_input[2]
        input_value = params[name]
        input = ParamsTransformer::Input.new(self, name, type, input_value, options)
        self.class.__send__(:attr_accessor, input.variable_name)
        instance_variable_set("@#{input.variable_name.to_s}", input.parsed_value)
        return input
      end

      # METHODS FOR CHILDREN
      def after_init(args)
        # this method is optionally implemented by children to
        # override default initialization behavior
      end
  end
end

