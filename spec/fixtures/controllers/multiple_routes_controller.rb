module Api
  module V1
    class MultipleRoutesController < ApplicationController
        swagger_controller :multiple_routes, "Multiple Routes"

        swagger_api :index do
        summary "Creates a new User"
        param :form, :first_name, :string, :required, "First name"
        response :unauthorized
      end
    end
  end
end
