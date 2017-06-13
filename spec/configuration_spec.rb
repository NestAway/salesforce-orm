require 'spec_helper'

RSpec.describe SalesforceOrm::Configuration do

  it 'should allow to set and get restforce_config' do
    expect(SalesforceOrm::Configuration.restforce_config).to be_nil

    config = {test: :ok}
    SalesforceOrm::Configuration.restforce_config=(config)
    expect(SalesforceOrm::Configuration.restforce_config).to eq(config)
  end
end
