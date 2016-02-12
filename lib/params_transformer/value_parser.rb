require 'params_transformer/value_parser/relationship'
require 'params_transformer/value_parser/attachment'
require 'params_transformer/value_parser/belongs_to'
require 'params_transformer/value_parser/boolean'
require 'params_transformer/value_parser/date'
require 'params_transformer/value_parser/datetime'
require 'params_transformer/value_parser/float'
require 'params_transformer/value_parser/has_many'
require 'params_transformer/value_parser/has_one'
require 'params_transformer/value_parser/integer'
require 'params_transformer/value_parser/nil_class'
require 'params_transformer/value_parser/phone'
require 'params_transformer/value_parser/string'
require 'params_transformer/value_parser/zip'

module ParamsTransformer
  class ValueParser

    attr_accessor :input_value

    def initialize(args = {})
      @input_value = args[:input_value]
      after_init(args)
    end

    def parse
      # implemented by child classes
    end

    def after_init(args)
      # optionally implemented by child classes
    end

  end
end
