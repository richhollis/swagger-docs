module Swagger
  module Docs
    class Config
      class << self
        def base_api_controller; ApplicationController end
        def register_apis(versions)
          base_api_controller.send(:include, ImpotentMethods)
          @versions = versions
        end
        def registered_apis
          @versions ||= {}
        end
      end
    end
  end
end
