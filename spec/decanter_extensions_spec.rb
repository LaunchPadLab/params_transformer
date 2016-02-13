require 'spec_helper'

describe Decanter::Extensions do

  before(:all) do
    Object.const_set('Model', Class.new do
      include Decanter::Extensions
      def initialize(args)
      end
    end)
  end

  describe '#decant' do

    context 'when a corresponding decanter does not exist' do
      it 'raises a name error' do
        expect { Model.decant({foo: 'bar'}) }
          .to raise_error(NameError, "unknown decanter ModelDecanter")
      end
    end

    context 'when a corresponding decanter exists' do

      before(:each) do
        Object.const_set('ModelDecanter', Class.new(Decanter::Base))
        allow(ModelDecanter).to receive(:decant)
      end

      it 'calls decant with the provided args on the decanter' do
        args = {foo: 'bar'}
        Model.decant(args)
        expect(ModelDecanter).to have_received(:decant).with(args)
      end
    end
  end
end
