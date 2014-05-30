module Swagger
  module Docs
    class ApiDeclarationFileMetadata
      DEFAULT_SWAGGER_VERSION = "1.2"

      attr_reader :api_version, :path, :base_path, :controller_base_path, :swagger_version, :camelize_model_properties

      def initialize(api_version, path, base_path, controller_base_path, options={})
        @api_version = api_version
        @path = path
        @base_path = base_path
        @controller_base_path = controller_base_path
        @swagger_version = options.fetch(:swagger_version, DEFAULT_SWAGGER_VERSION)
        @camelize_model_properties = options.fetch(:camelize_model_properties, true)
      end
    end
  end
end
