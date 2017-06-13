require 'spec_helper'

RSpec.describe SalesforceOrm::Configuration do

  klass = SalesforceOrm::Configuration

  it 'should allow to set and get restforce_config' do
    expect(klass.restforce_config).to be_nil

    config = {test: :ok}
    klass.restforce_config = config
    expect(klass.restforce_config).to eq(config)
    klass.restforce_config = nil
  end
end
