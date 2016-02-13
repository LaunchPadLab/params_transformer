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

    context 'when no context argument is provided' do
      it 'raises a name error' do
        expect { dummy.with_context(nil) { } }
          .to raise_error(NameError, 'no context argument provided to with_context')
      end
    end

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

    let(:parser) { double("parser", parse: nil) }

    before(:each) do
      allow(Decanter::ValueParser)
        .to receive(:value_parser_for)
        .and_return(parser)
    end

    it 'calls Decanter::ValueParser.value_parser_for with the given type' do
      dummy.parse(:foo, 'bar')
      expect(Decanter::ValueParser).to have_received(:value_parser_for).with(:foo)
    end

    it 'calls parse with the given value on the found parser' do
      dummy.parse(:foo, 'bar')
      expect(parser).to have_received(:parse).with('bar')
    end
  end

  describe '#decant' do

    before(:each) do
      allow(dummy).to receive(:parse) { |type, val| val }
    end

    it 'ignores fields without inputs' do
      dummy.decant({first_name: 'Dave'})
      expect(dummy.decant({first_name: 'Dave'})).to match({})
    end

    context 'with default context' do

      before(:each) do
        dummy.input :first_name, :string
      end

      context 'when context is not specified in the args' do
        it 'returns the parsed value' do
          expect(dummy.decant({first_name: 'Dave'})).to match({first_name: 'Dave'})
        end
      end

      context 'when context is specified in the args' do
        it 'ignores the field' do
          expect(dummy.decant({first_name: 'Dave'}, :baz)).to match({})
        end
      end
    end

    context 'when context configured' do

      before(:each) do
        dummy.input :first_name, :string, context: :baz
      end

      context 'when context is specified in the args' do
        it 'returns the parsed value' do
          expect(dummy.decant({first_name: 'Dave'}, :baz)).to match({first_name: 'Dave'})
        end
      end

      context 'when context is not specified in the args' do
        it 'ignores the field' do
          expect(dummy.decant({first_name: 'Dave'})).to match({})
        end
      end
    end
  end
end
