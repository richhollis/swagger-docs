module Swagger
  module Docs
    class ApiDeclarationFile
      attr_reader :metadata, :apis

      def initialize(metadata, apis, models)
        @metadata = metadata
        @apis = camelize_keys_deep apis
        @models = models
      end

      def generate_resource
        resource = build_resource_root_hash
        # Add the already-normalized models to the resource.
        resource = resource.merge({:models => models}) if models.present?
        resource
      end

      def base_path
        metadata.base_path
      end

      def path
        metadata.path
      end

      def swagger_version
        metadata.swagger_version
      end

      def api_version
        metadata.api_version
      end

      def controller_base_path
        metadata.controller_base_path
      end

      def camelize_model_properties
        metadata.camelize_model_properties
      end

      def resource_path
        metadata.overridden_resource_path || demod
      end

      def resource_file_path
        trim_leading_slash(debased_path.to_s.underscore)
      end

      def models
        normalize_model_properties @models
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

      def normalize_model_properties(models)
        Hash[
          models.map do |k, v|
            if camelize_model_properties
              [k.to_s, camelize_keys_deep(v)]
            else
              [k.to_s, stringify_keys_deep(v)]
            end
          end]
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
        process_keys_deep(obj){|key| key.to_s.camelize(:lower)}
      end

      def stringify_keys_deep(obj)
        process_keys_deep(obj){|key| key.to_s}
      end

      def process_keys_deep(obj, &block)
        if obj.is_a? Hash
          Hash[
            obj.map do |k, v|
              new_key =  block.call(k)
              new_value = process_keys_deep v, &block
              [new_key, new_value]
            end
          ]
        elsif obj.is_a? Array
          new_value = obj.collect do |a|
            process_keys_deep a, &block
          end
        else
          obj
        end
      end

    end
  end
end
