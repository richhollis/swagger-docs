module Swagger
  module Docs
    module ImpotentMethods

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        private

        def swagger_api(action, &block)
        end

        def swagger_model(model_name, &block)
        end

        def swagger_controller(controller, description)
        end
      end

    end
  end
end
