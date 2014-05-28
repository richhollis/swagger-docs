module Swagger
  module Docs
    class ApiDeclarationFile
      attr_reader :path, :apis, :models, :controller_base_path, :root

      def initialize(path, apis, models, controller_base_path, root)
        @path = path
        @apis = apis
        @models = models
        @controller_base_path = controller_base_path
        @root = root
      end

      def generate_resource
        resource = build_resource_root_hash
        camelize_keys_deep!(resource)
        camelize_keys_deep!(models)
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
          "resource_file_path" => resource_file_path
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

      def camelize_keys_deep!(h)
        h.keys.each do |k|
          ks    = k.to_s.camelize(:lower)
          h[ks] = h.delete k
          camelize_keys_deep! h[ks] if h[ks].kind_of? Hash
          if h[ks].kind_of? Array
            h[ks].each do |a|
              next unless a.kind_of? Hash
              camelize_keys_deep! a
            end
          end
        end
      end
    end
  end
end
