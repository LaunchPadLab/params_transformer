module ParamsTransformer
  class DirectoryParser
    attr_reader :current_class_name, :relevant_classes

    def initialize(args = {})
      @current_class_name = args[:current_class_name]
      @relevant_classes = set_relevant_classes
    end

    def set_relevant_classes
      relevant_classes = [current_class_name]
      classes = current_class_name.split("::")
      while classes.present?
        classes.pop
        possibility = classes.join("::")
        relevant_classes << possibility unless possibility.exclude?("::")
      end
      return relevant_classes
    end
  end
end
