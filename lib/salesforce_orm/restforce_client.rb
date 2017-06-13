require 'restforce'

module SalesforceOrm
  module RestforceClient

    module_function

    def instance
      # TODO need to verify with Sidekiq

      # Making Restforce object a thread local variable to avoid making
      # authentication request for each query we make to SalesForce.
      # With this, only one authentication request will be made to SalesForce
      # per request.
      #
      # Thread local variable will guarantee us a new Restforce object for each request.
      #
      # If this was a singleton object for process, then we'll have to
      # manually refresh authentication token for each request
      Thread.current[:salesforce_orm_restforce_client] ||= Restforce.new(Configuration.restforce_config || {})
    end

  end
end
