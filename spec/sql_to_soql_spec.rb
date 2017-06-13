require 'spec_helper'

RSpec.describe SalesforceOrm::SqlToSoql do

  it 'should convert 1=0 to id IS NULL'

  it 'should convert IS NOT to !='

  it 'should convert IS to ='

  it 'should fix datetime'

  it 'should fix date'

  it 'should fix boolean fields'

  it 'should convert aliased fields'
end
