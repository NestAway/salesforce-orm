require 'spec_helper'
require_relative 'fixtures/sample_object'

RSpec.describe SalesforceOrm::RecordTypeManager do

  it 'should have a constant call FIELD_NAME' do
    expect(SalesforceOrm::RecordTypeManager::FIELD_NAME).to eq(:RecordTypeId)
  end

  describe 'record_type_id' do

    let(:klass) do
      Class.new SampleObject
    end

    before(:each) do
      klass.record_type = :yo
    end

    describe 'Ruby ENV' do

      it 'should give nil record_type_id if there is not recordn type set' do
        klass.record_type = nil
        expect(klass.record_type_id).to be_nil
      end


      it 'should call fetch_record_type when first time' do
        id = 'bhla'
        expect(SampleObject).to receive(:fetch_record_type).and_return(
          SalesforceOrm::Object::RecordType.build({
            id: id
          })
        )
        expect(klass.record_type_id).to eq(id)
      end

      it 'should not call fetch_record_type if already fetched' do
        id = 'bhla'
        expect(klass).to receive(:fetch_record_type).and_return(
          SalesforceOrm::Object::RecordType.build({
            id: id
          })
        )
        expect(klass.record_type_id).to eq(id)

        expect(klass).not_to receive(:fetch_record_type)

        expect(klass.record_type_id).to eq(id)
      end
    end


    describe 'Rails ENV' do

      before(:all) do
        class TestEnv

          def env=(env)
            @env = env
          end

          def method_missing(method_name, *args, &block)
            method_name[0..-2] == @env
          end
        end

        class TestCache

          def self.fetch(*args)
            yield
          end

        end

        class ::Rails

          class << self
            def env
              @env ||= TestEnv.new
            end

            def env_name=(env_name)
              env.env = env_name
            end

            def cache
              TestCache
            end
          end
        end
      end

      it 'should return fake_record_type for test env' do
        Rails.env_name = 'test'

        expect(klass.record_type_id).to eq('fake_record_type')
      end

      it 'should call fetch_record_type in development env' do
        Rails.env_name = 'development'

        id = 'bhla'
        expect(klass).to receive(:fetch_record_type).and_return(
          SalesforceOrm::Object::RecordType.build({
            id: id
          })
        )
        expect(klass.record_type_id).to eq(id)
      end

      it 'should call Rails.cache evns expcept test and development' do
        Rails.env_name = 'production'

        expect(Rails).to receive(:cache).and_return(TestCache)

        id = 'bhla'
        expect(klass).to receive(:fetch_record_type).and_return(
          SalesforceOrm::Object::RecordType.build({
            id: id
          })
        )

        expect(klass.record_type_id).to eq('bhla')
      end
    end
  end
end
