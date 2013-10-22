module Swagger
  module Docs
    class Config
      class << self
        def register_apis(versions)
          ApplicationController.send(:include, ImpotentMethods)
          @versions = versions
        end
        def registered_apis
          @versions ||= {}
        end
      end
    end
  end
end