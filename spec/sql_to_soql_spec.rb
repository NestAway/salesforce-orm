require 'spec_helper'
require_relative 'fixtures/sample_object'

RSpec.describe SalesforceOrm::SqlToSoql do

  def remap_sample_object(field_map: nil, data_type_map: nil, object_name: nil)
    old_field_map = SampleObject.field_map
    old_data_type_map = SampleObject.data_type_map
    old_object_name = SampleObject.object_name

    SampleObject.field_map = field_map if field_map
    SampleObject.data_type_map = data_type_map if data_type_map
    SampleObject.object_name = object_name if object_name
    yield
    SampleObject.field_map = old_field_map
    SampleObject.data_type_map = old_data_type_map
    SampleObject.object_name = old_object_name
  end

  it 'should convert 1=0 to id IS NULL' do
    soql = SampleObject.where(id: []).to_soql
    expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE Id = NULL')
  end

  it 'should convert IS NOT to !=' do
    soql = SampleObject.where('id IS NOT NULL').to_soql
    expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE (id != NULL)')
  end

  it 'should convert IS to =' do
    soql = SampleObject.where(id: nil).to_soql
    expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE Id = NULL')
  end

  it 'should fix datetime' do
    t = Time.now
    t_str = t.utc.iso8601

    soql = SampleObject.where(created_at: t).to_soql
    expect(soql).to eq("SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE CreatedDate = #{t_str}")

    soql = SampleObject.where(created_at: [t, t]).to_soql
    expect(soql).to eq("SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE CreatedDate IN (#{t_str}, #{t_str})")
  end

  it 'should fix date' do
    d = Date.today
    d_str = d.to_s

    soql = SampleObject.where(created_at: d).to_soql
    expect(soql).to eq("SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE CreatedDate = #{d_str}")

    soql = SampleObject.where(created_at: [d, d]).to_soql
    expect(soql).to eq("SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE CreatedDate IN (#{d_str}, #{d_str})")
  end

  it 'should fix boolean fields' do
    remap_sample_object(data_type_map: {yo: :boolean}) do
      soql = SampleObject.where(yo: 0).to_soql
      expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE yo = false')

      soql = SampleObject.where(yo: 1).to_soql
      expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE yo = true')

      soql = SampleObject.where(yo: true).to_soql
      expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE yo = true')

      soql = SampleObject.where(yo: false).to_soql
      expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate FROM SampleObject WHERE yo = false')
    end
  end

  it 'should convert aliased fields' do
    remap_sample_object(field_map: {
      field_one: :FieldOne,
      field_two: :FieldTwo__c
    }) do
      soql = SampleObject.where(field_one: 'Hi', field_two: 333, yo: [1, 2, 3]).to_soql
      expect(soql).to eq('SELECT Id, CreatedDate, LastModifiedDate, FieldOne, FieldTwo__c FROM SampleObject WHERE FieldOne = \'Hi\' AND FieldTwo__c = 333 AND yo IN (1, 2, 3)')
    end
  end
end
