require 'spec_helper'
require_relative 'fixtures/sample_object'

require 'byebug'
require 'restforce'

RSpec.describe SalesforceOrm::ObjectBase do

  before(:all) do
    @sample_field_map = {
      field1: :fieldOne,
      field2: :fieldTwo__c
    }
  end

  def assign_field_map(new_field_map = nil)
    old_field_map = SampleObject.field_map
    SampleObject.field_map = new_field_map || @sample_field_map
    yield(SampleObject.field_map)
    SampleObject.field_map = old_field_map
  end

  it 'should allow to use custom object name' do
    expect(SampleObject.object_name).to eq(SampleObject.name)

    custom_object_name = 'SampleObject__c'
    SampleObject.object_name = custom_object_name

    expect(SampleObject.object_name).to eq(custom_object_name)

    SampleObject.object_name = SampleObject.name
  end

  it 'should allow set field alias' do
    expect(SampleObject.object_name).to eq(SampleObject.name)

    SampleObject.field_map = @sample_field_map

    expect(SampleObject.field_map).to eq(
      SalesforceOrm::ObjectMaker::DEFAULT_FIELD_MAP.merge(@sample_field_map)
    )

    SampleObject.field_map = SalesforceOrm::ObjectMaker::DEFAULT_FIELD_MAP
  end

  it 'should allow set data type' do
    expect(SampleObject.data_type_map).to eq(
      SalesforceOrm::ObjectMaker::DEFAULT_DATA_TYPE_MAP
    )

    custom_data_type_map = {yo: :date_time}

    SampleObject.data_type_map = custom_data_type_map

    expect(SampleObject.data_type_map).to eq(
      SalesforceOrm::ObjectMaker::DEFAULT_DATA_TYPE_MAP.merge(custom_data_type_map)
    )

    SampleObject.data_type_map = SalesforceOrm::ObjectMaker::DEFAULT_DATA_TYPE_MAP
  end

  describe 'create!' do
    it 'should call create! method of restforce' do
      assign_field_map do |field_map|
        expect(SalesforceOrm::RestforceClient.instance).to receive(:create!).with(
          SampleObject.object_name,
          field_map[:field1] => :yo
        )
        SampleObject.create!({field1: :yo})
      end
    end
  end

  describe 'update_all!' do
    it 'should call update_attributes! for each matched object' do
      attributes = {yo: :yo}
      results = [SampleObject.build({})]

      results.each do |obj|
        expect(obj).to receive(:update_attributes!).with(attributes)
      end

      expect_any_instance_of(SalesforceOrm::Base).to receive(
        :make_query
      ).and_return(results)

      SampleObject.scoped.update_all!(attributes)
    end
  end

  describe 'update_by_id!' do
    it 'should call update! method of restforce with given id' do
      assign_field_map do |field_map|
        expect(SalesforceOrm::RestforceClient.instance).to receive(:update!).with(
          SampleObject.object_name,
          field_map[:field1] => :yo,
          field_map[:id] => 1
        )
        SampleObject.update_by_id!(1, {field1: :yo})
      end
    end
  end

  describe 'destroy_all!' do
    it 'should call destroy! for each matched object' do
      results = [SampleObject.build({})]

      results.each do |obj|
        expect(obj).to receive(:destroy!)
      end

      expect_any_instance_of(SalesforceOrm::Base).to receive(
        :make_query
      ).and_return(results)

      SampleObject.scoped.destroy_all!
    end
  end

  describe 'destroy_by_id!' do
    it 'should call destroy! method of restforce with given id' do
      assign_field_map do |field_map|
        expect(SalesforceOrm::RestforceClient.instance).to receive(:destroy!).with(
          SampleObject.object_name, 1
        )
        SampleObject.destroy_by_id!(1)
      end
    end
  end

  describe 'where' do
    it 'should allow chained call' do
      soql = SampleObject.where(yo: 3, yoyo: 'Uiew').to_soql
      expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE yo = 3 AND yoyo = \'Uiew\'')
    end
  end

  describe 'select' do
    it 'should by default select all fields' do
      assign_field_map do |field_map|
        soql = SampleObject.scoped.to_soql
        expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate, fieldOne, fieldTwo__c FROM SampleObject')
      end
    end

    it 'should select given fields' do
      soql = SampleObject.select(:id).to_soql
      expect(soql).to eq('SELECT Id FROM SampleObject')
    end
  end

  describe 'except' do
    it 'should remove previously chained method' do
      soql = SampleObject.select(:id).except(:select).select(:created_at).to_soql
      expect(soql).to eq('SELECT CreatedDate FROM SampleObject')
    end
  end

  describe 'group' do
    it 'should add group by to query' do
      soql = SampleObject.group(:id, :created_at)
      expect(soql).to eq('SELECT CreatedDate FROM SampleObject')
    end
  end

  describe 'order' do
    it 'should add order by to query'
  end

  describe 'reorder' do
    it 'should reset the previous order'
  end

  describe 'limit' do
    it 'should add limit to query'
  end

  describe 'offset' do
    it 'should add offset to query'
  end

  describe 'first' do
    it 'should call limit and and first of ORM'
  end

  describe 'last' do
    it 'should call limit, order and and first of ORM'
  end

  describe 'each' do
    it 'should call each of ORM'
  end

  describe 'scoped' do
    it 'should create default scope in the chain'
  end

  describe 'all' do
    it 'should call restforce with given query'
  end

  describe 'to_soql' do
    it 'should call to_soql'
  end

  describe 'build' do
    it 'should create a object with given values'
  end

  describe 'find' do
    it 'should call restforce with id query'
  end

  describe 'find_by_*' do
    it 'should automatically generate query based on method name'
  end

  describe 'update_attributes!' do
    it 'should call restforce with update query'
  end

  describe 'destroy!' do
    it 'should call restforce destroy method'
  end

end
