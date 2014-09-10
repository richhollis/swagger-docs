module Swagger
  module Docs
    class Config
      class << self
        @@base_api_controller = nil

        def base_api_controller
          @@base_api_controller || ActionController::Base
        end

        def base_api_controller=(controller)
          @@base_api_controller = controller
        end

        def base_applications
          Array(base_application)
        end

        def base_application
          Rails.application 
        end

        def register_apis(versions)
          base_api_controller.send(:include, ImpotentMethods)
          @versions = versions
        end

        def registered_apis
          @versions ||= {}
        end
        
        def transform_path(path, api_version)
          # This is only for overriding, so don't perform any path transformations by default.
          path
        end

        def log_exception
          yield
          rescue => e
            write_log(:error, e)
            raise
        end

        def log_env_name
          'SD_LOG_LEVEL'
        end

        def write_log(type, output)
          $stderr.puts output if type == :error and ENV[log_env_name]=="1"
        end

      end
    end
  end
end
