module Api
  module V1
    class SampleController < ApplicationController

      swagger_controller :users, "User Management"

      swagger_api :index do
        summary "Fetches all User items"
        param :query, :page, :integer, :optional, "Page number"
        response :unauthorized
        response :not_acceptable
        response :requested_range_not_satisfiable
      end

      swagger_api :show do
        summary "Fetches a single User item"
        param :path, :id, :integer, :optional, "User Id"
        response :unauthorized
        response :not_acceptable
        response :not_found
      end

      swagger_api :create do
        summary "Creates a new User"
        param :form, :first_name, :string, :required, "First name"
        param :form, :last_name, :string, :required, "Last name"
        param :form, :email, :string, :required, "Email address"
        response :unauthorized
        response :not_acceptable
      end

      swagger_api :update do
        summary "Updates an existing User"
        param :path, :id, :integer, :required, "User Id"
        param :form, :first_name, :string, :optional, "First name"
        param :form, :last_name, :string, :optional, "Last name"
        param :form, :email, :string, :optional, "Email address"
        response :unauthorized
        response :not_found
        response :not_acceptable
      end

      swagger_api :destroy do
        summary "Deletes an existing User item"
        param :path, :id, :integer, :optional, "User Id"
        response :unauthorized
        response :not_found
      end

    end
  end
end