require 'spec_helper'
require 'byebug'
require_relative 'fixtures/sample_object'

RSpec.describe SalesforceOrm::ObjectBase do

  it 'should allow to use custom object name' do
    expect(SampleObject.object_name).to eq(SampleObject.name)

    custom_object_name = 'SampleObject__c'
    SampleObject.object_name = custom_object_name

    expect(SampleObject.object_name).to eq(custom_object_name)

    SampleObject.object_name = SampleObject.name
  end

  it 'should allow set field alias' do

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
    it 'should call create! method of restforce'
  end

  describe 'update_all!' do
    it 'should call update_attributes! for each matched object'
  end

  describe 'update_by_id!' do
    it 'should call update! method of restforce with given id'
  end

  describe 'destroy_all!' do
    it 'should call destroy! for each matched object'
  end

  describe 'destroy_by_id!' do
    it 'should call destroy! method of restforce with given id'
  end

  describe 'where' do
    it 'should allow chained call'
  end

  describe 'select' do
    it 'should by default select all fields'

    it 'should select given fields'
  end

  describe 'except' do
    it 'should remove previously chained method'
  end

  describe 'group' do
    it 'should add group by to query'
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
