module Decanter

  @@decanters = {}

  def self.register(decanter)
    @@decanters[decanter.name] = decanter
  end

  def self.decanter_for(klass)
    @@decanters["#{klass.name}Decanter"] || (raise NameError.new("unknown decanter #{klass.name}Decanter"))
  end
end

require 'decanter/base'
require 'decanter/core'
require 'decanter/extensions'
require 'decanter/value_parser'
