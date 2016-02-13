module Decanter
  module Extensions

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def decant_update(args={}, context=nil)
        self.attributes = decant(args, context)
        self.save(context: context)
      end

      def decant_update!(args={}, context=nil)
        self.attributes = decant(args, context)
        self.save!(context: context)
      end

      def decant_create(args={}, context=nil)
        self.new(decant(args, context))
        self.save(context: context)
      end

      def decant_create!(args={}, context=nil)
        self.new(decant(args, context))
        self.save!(context: context)
      end

      private
        def decant(args, context)
          decanter_for(self).decant(args, context)
        end
    end
  end
end
ActiveRecord::Base.include(Decanter::Extensions) if defined? ActiveRecord
