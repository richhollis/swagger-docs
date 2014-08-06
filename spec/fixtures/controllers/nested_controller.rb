module Api
  module V1
    class SuperclassController < ApplicationController
    end
    class NestedController < SuperclassController
      swagger_controller :nested, "User Management"

      swagger_api :index do
        summary "Fetches all User items"
        param :query, :page, :integer, :optional, "Page number"
        param :path, :nested_id, :integer, :optional, "Team Id"
        response :unauthorized
        response :not_acceptable, "The request you made is not acceptable"
        response :requested_range_not_satisfiable
      end
    end
  end
end
