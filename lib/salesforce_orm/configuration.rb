module SalesforceOrm
  class Configuration

    class << self

      def restforce_config=(config)
        @restforce_config = DEFAULT_CONFIG.merge(config)
      end

      def restforce_config
        @restforce_config
      end

    end
  end
end
