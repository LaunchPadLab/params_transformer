require 'spec_helper'

describe Decanter::Core do

  before(:each) do
    Decanter::Core.class_variable_set(:@@inputs, {})
    Decanter::Core.class_variable_set(:@@associations, {})
  end

  after(:each) do
    Decanter::Core.class_variable_set(:@@inputs, {})
    Decanter::Core.class_variable_set(:@@associations, {})
  end

  let(:dummy) { Class.new { include Decanter::Core } }

  describe '#input' do

    it 'adds an input with the default context' do
      dummy.input :first_name, :string
      expect(dummy.inputs).to include(default: {
        first_name: {
          name: :first_name,
          type: :string,
          options: {}
        }
      })
    end

    it 'adds an input with the specified context' do
      dummy.input :first_name, :string, context: :foo
      expect(dummy.inputs).to include(foo: {
        first_name: {
          name: :first_name,
          type: :string,
          options: {}
        }
      })
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
        expect(dummy.inputs).to include(foo: {
          first_name: {
            name: :first_name,
            type: :string,
            options: {}
          },
          last_name: {
            name: :last_name,
            type: :integer,
            options: {}
          }
        })
      end
    end

    context 'without an argument' do
      it 'add inputs with the specified context' do
        dummy.with_context :foo do
          input :first_name, :string
          input :last_name,  :integer
        end
        expect(dummy.inputs).to include(foo: {
          first_name: {
            name: :first_name,
            type: :string,
            options: {}
          },
          last_name: {
            name: :last_name,
            type: :integer,
            options: {}
          }
        })
      end
    end
  end

  describe '#has_one' do

    it 'adds a has_one association with the default context' do
      dummy.has_one :profile
      expect(dummy.associations).to include(default: {
        profile: {
          key:  :profile_attributes,
          name: :profile,
          type: :has_one,
          options: {}
        }
      })
    end

    it 'adds an input with the specified context' do
      dummy.has_one :profile, context: :foo
      expect(dummy.associations).to include(foo: {
        profile: {
          key:  :profile_attributes,
          name: :profile,
          type: :has_one,
          options: {}
        }
      })
    end
  end

  describe '#has_many' do

    it 'adds a has_one association with the default context' do
      dummy.has_many :profiles
      expect(dummy.associations).to include(default: {
        profiles: {
          key:  :profiles_attributes,
          name: :profiles,
          type: :has_many,
          options: {}
        }
      })
    end

    it 'adds an input with the specified context' do
      dummy.has_many :profiles, context: :foo
      expect(dummy.associations).to include(foo: {
        profiles: {
          key:  :profiles_attributes,
          name: :profiles,
          type: :has_many,
          options: {}
        }
      })
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
      dummy.input :first_name, :string
      dummy.input :last_name,  :string, context: :foo
      dummy.input :phone,      :string, context: :bar
      dummy.has_one :profile, context: :foo
      dummy.has_many :photos, context: :foo
    end

    context 'without context' do

      context 'for an argument without an input' do
        it 'includes the field' do
          expect(dummy.decant({nickname: 'dc'})).to match({nickname: 'dc'})
        end
      end

      context 'for an argument an input' do
        it 'includes the field' do
          expect(dummy.decant({first_name: 'Dave'})).to match({first_name: 'Dave'})
        end
      end
    end

    context 'with context' do

      context 'for an argument without an input' do
        it 'does not include the field' do
          expect(dummy.decant({nickname: 'dc'}, :foo)).to match({})
        end
      end

      context 'for an argument with an input in the default context' do
        it 'does not include the field' do
          expect(dummy.decant({first_name: 'Dave'}, :foo)).to match({})
        end
      end

      context 'for an argument with an input for that context' do
        it 'includes the field' do
          expect(dummy.decant({last_name: 'Corwin'}, :foo)).to match({last_name: 'Corwin'})
        end
      end

      context 'for an argument with an input for a different context' do
        it 'includes the field' do
          expect(dummy.decant({phone: '123456789'}, :foo)).to match({})
        end
      end

      context 'for an argument with a has_one association for that context' do

        before(:each) do
          foo = Class.new do
            def self.name
              'ProfileDecanter'
            end
          end
          foo.include Decanter::Core
          foo.input :is_cool, :boolean, context: :foo
          allow(foo).to receive(:parse) { |type, val| val }
        end

        it 'includes the field' do
          expect(dummy.decant({profile_attributes: { is_cool: false } }, :foo))
            .to match({profile_attributes: { is_cool: false } })
        end
      end

      context 'for an argument with a has_many association for that context' do

        before(:each) do
          foo = Class.new do
            def self.name
              'PhotoDecanter'
            end
          end
          foo.include Decanter::Core
          foo.input :title, :string, context: :foo
          allow(foo).to receive(:parse) { |type, val| val }
        end

        it 'includes the field' do
          expect(dummy.decant({photos_attributes: [{title: 'foobar'}, {title: 'baz'}] }, :foo))
            .to match({photos_attributes: [{title: 'foobar'}, {title: 'baz'}] })
        end
      end
    end
  end
end
