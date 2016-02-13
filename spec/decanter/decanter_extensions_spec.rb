require 'spec_helper'

describe Decanter::Extensions do

  let(:dummy) { Class.new { include Decanter::Extensions } }

  before(:each) do
    allow(dummy).to receive(:attributes=)
    allow(dummy).to receive(:decant) { |args, context| args }
    allow(dummy).to receive(:new)
    allow(dummy).to receive(:save)
    allow(dummy).to receive(:save!)
  end

  shared_examples 'a decanter update' do |strict|

    let(:args) { { foo: 'bar' } }

    context 'with no context' do

      before(:each) { strict ?
                        dummy.decant_update!(args) :
                        dummy.decant_update(args)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy).to have_received(:attributes=).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model" do
        expect(dummy).to have_received( strict ? :save! : :save )
      end
    end

    context 'with context' do

      let(:_context) { :foo }

      before(:each) { strict ?
                        dummy.decant_update!(args, _context) :
                        dummy.decant_update(args, _context)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy).to have_received(:attributes=).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model with the context" do
        expect(dummy)
          .to have_received(strict ? :save! : :save)
          .with(context: _context)
      end
    end
  end

  shared_examples 'a decanter create' do |strict|

    let(:args) { { foo: 'bar' } }

    context 'with no context' do

      before(:each) { strict ?
                        dummy.decant_create!(args) :
                        dummy.decant_create(args)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy).to have_received(:new).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model" do
        expect(dummy).to have_received( strict ? :save! : :save )
      end
    end

    context 'with context' do

      let(:_context) { :foo }

      before(:each) { strict ?
                        dummy.decant_create!(args, _context) :
                        dummy.decant_create(args, _context)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy).to have_received(:new).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model with the context" do
        expect(dummy)
          .to have_received(strict ? :save! : :save)
          .with(context: _context)
      end
    end
  end

  describe '#decant_update' do
    it_behaves_like 'a decanter update'
  end

  describe '#decant_update!' do
    it_behaves_like 'a decanter update', true
  end

  describe '#decant_create' do
    it_behaves_like 'a decanter create'
  end

  describe '#decant_create!' do
    it_behaves_like 'a decanter create', true
  end
end
