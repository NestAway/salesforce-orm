module SalesforceOrm
  module Error

    # A general exception
    class Base < StandardError; end

    class CommonError < Base; end

    class ObjectNotFound < Base; end
  end
end
