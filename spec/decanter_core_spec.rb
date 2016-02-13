require 'spec_helper'

describe Decanter::Core do

  let(:dummy) { Class.new { include Decanter::Core } }

  describe '#input' do
    it 'adds an input with the default context' do
      dummy.input :name, :string
      expect(dummy.inputs).to include(default: {name: :string})
    end

    it 'adds an input with the specified context' do
      dummy.input :name, :string, context: :foo
      expect(dummy.inputs).to include(foo: {name: :string})
    end
  end

  describe '#with_options' do

    context 'with an argument' do
      it 'add inputs with the specified context' do
        dummy.with_context :foo do |d|
          d.input :first_name, :string
          d.input :last_name,  :integer
        end
        expect(dummy.inputs).to include(foo: {first_name: :string, last_name: :integer})
      end
    end

    context 'without an argument' do
      it 'add inputs with the specified context' do
        dummy.with_context :foo do
          input :first_name, :string
          input :last_name,  :integer
        end
        expect(dummy.inputs).to include(foo: {first_name: :string, last_name: :integer})
      end
    end
  end

  describe '#parse' do

    context 'for a parser that exists' do

      before(:each) do
        Object.const_set('FooParser', Class.new(Decanter::ValueParser))
        allow(FooParser).to receive(:parse)
      end

      it 'calls parse on the parser with the value' do
        dummy.parse(:foo, 'bar')
        expect(FooParser).to have_received(:parse).with('bar')
      end
    end

    context 'for a parser that does not exist' do
      it 'throws a name error' do
        expect { dummy.parse(:baz, 'bar') }
          .to raise_error(NameError, "unknown value parser: #{:baz}")
      end
    end
  end

  describe '#decant' do

    before(:each) do
      allow(dummy).to receive(:parse)
    end

    it 'ignores fields without inputs' do
      dummy.decant({first_name: 'Dave'})
      expect(dummy).to_not have_received(:parse)
    end

    context 'with default context' do

      before(:each) do
        dummy.input :first_name, :string
      end

      context 'when context is not specified in the args' do
        it 'calls parse with the input type and value' do
          dummy.decant({first_name: 'Dave'})
          expect(dummy).to have_received(:parse).with(:string, 'Dave')
        end
      end

      context 'when context is specified in the args' do
        it 'does not call parse with the input type and value' do
          dummy.decant({context: :baz, first_name: 'Dave'})
          expect(dummy).to_not have_received(:parse)
        end
      end
    end

    context 'when context configured' do

      before(:each) do
        dummy.input :first_name, :string, context: :baz
      end

      context 'when context is specified in the args' do
        it 'calls parse with the input type and value' do
          dummy.decant({context: :baz, first_name: 'Dave'})
          expect(dummy).to have_received(:parse).with(:string, 'Dave')
        end
      end

      context 'when context is not specified in the args' do
        it 'does not call parse' do
          dummy.decant({first_name: 'Dave'})
          expect(dummy).to_not have_received(:parse)
        end
      end
    end
  end
end
