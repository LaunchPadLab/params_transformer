module Decanter
  module Extensions

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def decant(args)
        decanter = ObjectSpace.each_object(Class)
                              .detect { |klass| klass      <  Decanter::Base &&
                                                klass.name == "#{self.name}Decanter" }

        raise NameError.new("unknown decanter #{self.name}Decanter") unless decanter

        self.new(decanter.decant(args))
      end
    end
  end
end
ActiveRecord::Base.include(Decanter::Extensions) if defined? ActiveRecord
