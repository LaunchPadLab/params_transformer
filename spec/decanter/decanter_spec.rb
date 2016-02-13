require 'spec_helper'

describe Decanter do

  describe '#register' do
    before(:each) { Decanter.class_variable_set(:@@decanters, {}) }
    after(:each) { Decanter.class_variable_set(:@@decanters, {}) }

    it 'adds the class to the array of decanters' do
      foo = Class.new do
        def self.name
          'Foo'
        end
      end
      Decanter.register(foo)
      expect(Decanter.class_variable_get(:@@decanters)).to match({'Foo' => foo})
    end
  end

  describe '#decanter_for' do

    context 'when a corresponding decanter does not exist' do
      it 'raises a name error' do
        expect { Decanter::decanter_for(String) }
          .to raise_error(NameError, "unknown decanter StringDecanter")
      end
    end

    context 'when a corresponding decanter exists' do

      let(:model_decanter) do
        Class.new do
          def self.name
            'ModelDecanter'
          end
        end
      end

      let(:model) do
        Class.new do
          def self.name
            'Model'
          end
        end
      end
      before(:each) do
        Decanter.register(model_decanter)
      end

      it 'returns the decanter' do
        expect(Decanter::decanter_for(model)).to eq model_decanter
      end
    end
  end
end
