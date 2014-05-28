module Swagger
  module Docs
    class ApiDeclarationFile
      attr_reader :path, :apis, :models, :controller_base_path, :root

      def initialize(path, apis, models, controller_base_path, root)
        @path = path
        @apis = camelize_keys_deep apis
        @models = camelize_keys_deep models
        @controller_base_path = controller_base_path
        @root = root
      end

      def generate_resource
        resource = build_resource_root_hash
        # Add the already-normalized models to the resource.
        resource = resource.merge({:models => models}) if models.present?
        resource
      end

      def base_path
        root["basePath"]
      end

      def swagger_version
        root["swaggerVersion"]
      end

      def api_version
        root["apiVersion"]
      end

      def resource_path
        demod
      end

      def resource_file_path
        trim_leading_slash(debased_path.to_s.underscore)
      end

      private

      def build_resource_root_hash
        {
          "apiVersion" => api_version,
          "swaggerVersion" => swagger_version,
          "basePath" => base_path,
          "resourcePath" => resource_path,
          "apis" => apis,
          "resourceFilePath" => resource_file_path
        }
      end


      def demod
        "#{debased_path.to_s.camelize}".demodulize.camelize.underscore
      end

      def debased_path
        path.gsub("#{controller_base_path}", "")
      end

      def trim_leading_slash(str)
        return str if !str
        str.gsub(/\A\/+/, '')
      end

      def camelize_keys_deep(obj)
        if obj.is_a? Hash
          Hash[
            obj.map do |k, v|
              new_key =  k.to_s.camelize(:lower)
              new_value = camelize_keys_deep v
              [new_key, new_value]
            end
          ]
        elsif obj.is_a? Array
          new_value = obj.collect do |a|
            camelize_keys_deep a
          end
        else
          obj
        end
      end
    end
  end
end
