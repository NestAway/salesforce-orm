require 'spec_helper'
require_relative 'fixtures/sample_object'

RSpec.describe SalesforceOrm::Base do

  it 'should use valid config for restforce' do
    SalesforceOrm::Configuration.restforce_config = nil
    expect(Restforce).to receive(:new).with({})
    SalesforceOrm::Base.new(SampleObject)

    config = {test: :test}

    SalesforceOrm::Configuration.restforce_config = config
    expect(Restforce).to receive(:new).with(config)
    SalesforceOrm::Base.new(SampleObject)
  end
end
