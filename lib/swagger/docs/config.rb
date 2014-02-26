module Swagger
  module Docs
    class Config
      class << self
        def base_api_controller; ActionController::Base end
        def base_application; Rails.application end
        def register_apis(versions)
          base_api_controller.send(:include, ImpotentMethods)
          @versions = versions
        end
        def registered_apis
          @versions ||= {}
        end
        def transform_path(path)
          # This is only for overriding, so don't perform any path transformations by default.
          path
        end
      end
    end
  end
end
