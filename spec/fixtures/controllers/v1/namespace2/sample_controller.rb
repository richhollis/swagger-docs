module Api
  module Namespace2
  end
  module V1
    class SuperclassController < ApplicationController
    end
    class Namespace2::SampleController < SuperclassController
      swagger_controller :users, "User Management"

      swagger_api :index do
        summary "Fetches all User items"
        param :query, :page, :integer, :optional, "Page number"
        response :unauthorized
        response :not_acceptable, "The request you made is not acceptable"
        response :requested_range_not_satisfiable
      end
    end
  end
end
