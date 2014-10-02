module Api
  module V1
    class SuperclassController < ApplicationController
    end
    class SampleController < SuperclassController
      swagger_controller :users, "User Management"

      swagger_api :index do
        summary "Fetches all User items"
        param :query, :page, :integer, :optional, "Page number"
        param :path, :nested_id, :integer, :optional, "Team Id"
        response :ok, "Some text", :Tag
        response :unauthorized
        response :not_acceptable, "The request you made is not acceptable"
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
        consumes [ "application/json", "text/xml" ]
        param :form, :first_name, :string, :required, "First name"
        param :form, :last_name, :string, :required, "Last name"
        param :form, :email, :string, :required, "Email address"
        param_list :form, :role, :string, :required, "Role", [ "admin", "superadmin", "user" ]
        param :body, :body, :json, :required, 'JSON formatted body'
        response :unauthorized
        response :not_acceptable
      end

      swagger_api :update do
        summary "Updates an existing User"
        notes "Only the given fields are updated."
        param :path, :id, :integer, :required, "User Id"
        param :form, :first_name, :string, :optional, "First name"
        param :form, :last_name, :string, :optional, "Last name"
        param :form, :email, :string, :optional, "Email address"
        param :form, :tag, :Tag, :required, "Tag object"
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

      # a method that intentionally has no parameters
      swagger_api :new do
        summary "Builds a new User item"
      end

      swagger_api :context_dependent do
        summary "An action dependent on the context of the controller " +
          "class. Right now it is: " + ApplicationController.context
        response :ok
        response :unauthorized
      end

      # Support for Swagger complex types:
      # https://github.com/wordnik/swagger-core/wiki/Datatypes#wiki-complex-types
      swagger_model :Tag do
        description "A Tag object."
        property :id, :integer, :required, "User Id"
        property :name, :string, :optional, "Name", foo: "test"
      end
    end
  end
end
