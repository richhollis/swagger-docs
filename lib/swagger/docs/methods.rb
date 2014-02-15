module Swagger
  module Docs
    module Methods
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def swagger_controller(controller, description)
          swagger_config[:controller] = controller
          swagger_config[:description] = description
        end

        def swagger_actions
          @swagger_dsl
        end

        def swagger_models
          @swagger_model_dsls
        end

        def swagger_config
          @swagger_config ||= {}
        end

        private

        def swagger_api(action, &block)
          @swagger_dsl ||= {}
          controller_action = "#{name}##{action} #{self.class}"
          return if @swagger_dsl[action]
          route = Swagger::Docs::Config.base_application.routes.routes.select{|i| "#{i.defaults[:controller].to_s.camelize}Controller##{i.defaults[:action]}" == controller_action }.first
          dsl = SwaggerDSL.call(action, self, &block)
          @swagger_dsl[action] = dsl
        end

        def swagger_model(model_name, &block)
          @swagger_model_dsls ||= {}
          model_dsl = SwaggerModelDSL.call(model_name, self, &block)
          @swagger_model_dsls[model_name] = model_dsl
        end
      end
    end
  end
end
