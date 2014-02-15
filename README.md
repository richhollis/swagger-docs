# Swagger::Docs

Generates swagger-ui json files for rails apps with APIs. You add the swagger DSL to your controller classes and then run one rake task to generate the json files.

Here is an extract of the DSL from a user controller API class:

```ruby
swagger_controller :users, "User Management"

swagger_api :index do
  summary "Fetches all User items"
  param :query, :page, :integer, :optional, "Page number"
  response :unauthorized
  response :not_acceptable
  response :requested_range_not_satisfiable
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'swagger-docs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install swagger-docs

## Usage

### Create Initializer

Create an initializer in config/initializers (e.g. swagger_docs.rb) and define your APIs:

```ruby
Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/api/v1/",
    # the URL base path to your API
    :base_path => "http://api.somedomain.com",
    # if you want to delete all .json files at each generation
    :clean_directory => false
  }
})
```

#### Configuration options

The following table shows all the current configuration options and their defaults. The default will be used if you don't supply your own value.

<table>
<thead>
<tr>
<th>Option</th>
<th>Description</th>
<th>Default</th>
</tr>
</thead>
<tbody>

<tr>
<td><b>api_extension_type</b></td>
<td>The extension, if necessary, used for your API - e.g. :json or :xml </td>
<td>nil</td>
</tr>

<tr>
<td><b>api_file_path</b></td>
<td>The output file path where generated swagger-docs files are written to. </td>
<td>public/</td>
</tr>

<tr>
<td><b>base_path</b></td>
<td>The URI base path for your API - e.g. api.somedomain.com</td>
<td>/</td>
</tr>

<tr>
<td><b>clean_directory</b></td>
<td>When generating swagger-docs files this option specifies if the api_file_path should be cleaned first. This means that all files will be deleted in the output directory first before any files are generated.</td>
<td>false</td>
</tr>

<tr>
<td><b>formatting</b></td>
<td>Specifies which formatting method to apply to the JSON that is written. Available options: :none, :pretty</td>
<td>:pretty</td>
</tr>

</tbody>
</table>


### Documenting a controller

```ruby
class Api::V1::UsersController < ApplicationController

  swagger_controller :users, "User Management"

  swagger_api :index do
    summary "Fetches all User items"
    param :query, :page, :integer, :optional, "Page number"
    param :path, :nested_id, :integer, :optional, "Team Id"
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

  # Support for Swagger complex types:
  # https://github.com/wordnik/swagger-core/wiki/Datatypes#wiki-complex-types
  swagger_model :Tag do
    description "A Tag object."
    property :id, :integer, :required, "User Id"
    property :name, :string, :optional, "Name"
  end

end
```

### Run rake task to generate docs

```
rake swagger:docs
```

Swagger-ui JSON files should now be present in your api_file_path (e.g. ./public/api/v1)

### Sample

A sample Rails application where you can run the above rake command and view the output in swagger-ui can be found here:

https://github.com/richhollis/swagger-docs-sample

![Screen shot 1](https://github.com/richhollis/swagger-docs-sample/raw/master/swagger-docs-screenshot-2.png)


### Advanced Customization

#### Inheriting from a custom Api controller

By default swagger-docs is applied to controllers inheriting from ApplicationController.
If this is not the case for your application, use this snippet in your initializer
_before_ calling Swagger::Docs::Config#register_apis(...).

```ruby
class Swagger::Docs::Config
  def self.base_api_controller; Api::ApiController end
end
```

#### Custom route discovery for supporting Rails Engines

By default, swagger-docs finds controllers by traversing routes in `Rails.application`.
To override this, you can customize the `base_application` config in an initializer:

```ruby
class Swagger::Docs::Config
  def self.base_application; Api::Engine end
end
```

#### Transforming the `path` variable

Swagger allows a distinction between the API documentation server and the hosted API
server through the `path` variable (see [Swagger: No server Integrations](https://github.com/wordnik/swagger-core/wiki/No-server-Integrations)). To override the default swagger-docs behavior, you can provide a `transform_path`
class method in your initializer:

```ruby
class Swagger::Docs::Config
  def self.transform_path(path)
    "http://example.com/api-docs/#{path}"
  end
end
```

The transformation will be applied to all API `path` values in the generated `api-docs.json` file.

#### Precompile

It is best-practice *not* to keep documentation in version control. An easy way
to integrate swagger-docs into a conventional deployment setup (e.g. capistrano,
chef, or opsworks) is to piggyback on the 'assets:precompile' rake task. And don't forget
to add your api documentation directory to .gitignore in this case.

```ruby
#Rakefile or lib/task/precompile_overrides.rake
namespace :assets do
  task :precompile do
    Rake::Task['assets:precompile'].invoke
    Rake::Task['swagger:docs'].invoke
  end
end
```

### Output files

api-docs.json output:


```json
{
  "apiVersion": "1.0",
  "swaggerVersion": "1.2",
  "basePath": "/api/v1",
  "apis": [
    {
      "path": "/users.{format}",
      "description": "User Management"
    }
  ]
}
```

users.json output:

```json
{
  "apiVersion": "1.0",
  "swaggerVersion": "1.2",
  "basePath": "http://api.somedomain.com/api/v1/",
  "resourcePath": "/users",
  "apis": [
    {
      "path": "/users",
      "operations": [
        {
          "summary": "Fetches all User items",
          "parameters": [
            {
              "paramType": "query",
              "name": "page",
              "type": "integer",
              "description": "Page number",
              "required": false
            }
          ],
          "responseMessages": [
            {
              "code": 401,
              "message": "Unauthorized"
            },
            {
              "code": 406,
              "message": "The request you made is not acceptable"
            },
            {
              "code": 416,
              "message": "Requested Range Not Satisfiable"
            }
          ],
          "method": "get",
          "nickname": "Api::V1::Users#index"
        }
      ]
    },
    {
      "path": "nested/{nested_id}/sample",
      "operations": [
        {
          "summary": "Fetches all User items",
          "parameters": [
            {
              "paramType": "query",
              "name": "page",
              "type": "integer",
              "description": "Page number",
              "required": false
            },
            {
              "paramType": "path",
              "name": "nested_id",
              "type": "integer",
              "description": "Team Id",
              "required": false
            }
          ],
          "responseMessages": [
            {
              "code": 401,
              "message": "Unauthorized"
            },
            {
              "code": 406,
              "message": "The request you made is not acceptable"
            },
            {
              "code": 416,
              "message": "Requested Range Not Satisfiable"
            }
          ],
          "method": "get",
          "nickname": "Api::V1::Users#index"
        }
      ]
    },
    {
      "path": "/users",
      "operations": [
        {
          "summary": "Creates a new User",
          "parameters": [
            {
              "paramType": "form",
              "name": "first_name",
              "type": "string",
              "description": "First name",
              "required": true
            },
            {
              "paramType": "form",
              "name": "last_name",
              "type": "string",
              "description": "Last name",
              "required": true
            },
            {
              "paramType": "form",
              "name": "email",
              "type": "string",
              "description": "Email address",
              "required": true
            }
          ],
          "responseMessages": [
            {
              "code": 401,
              "message": "Unauthorized"
            },
            {
              "code": 406,
              "message": "Not Acceptable"
            }
          ],
          "method": "post",
          "nickname": "Api::V1::Users#create"
        }
      ]
    },
    {
      "path": "/users/{id}",
      "operations": [
        {
          "summary": "Fetches a single User item",
          "parameters": [
            {
              "paramType": "path",
              "name": "id",
              "type": "integer",
              "description": "User Id",
              "required": false
            }
          ],
          "responseMessages": [
            {
              "code": 401,
              "message": "Unauthorized"
            },
            {
              "code": 404,
              "message": "Not Found"
            },
            {
              "code": 406,
              "message": "Not Acceptable"
            }
          ],
          "method": "get",
          "nickname": "Api::V1::Users#show"
        }
      ]
    },
    {
      "path": "/users/{id}",
      "operations": [
        {
          "summary": "Updates an existing User",
          "parameters": [
            {
              "paramType": "path",
              "name": "id",
              "type": "integer",
              "description": "User Id",
              "required": true
            },
            {
              "paramType": "form",
              "name": "first_name",
              "type": "string",
              "description": "First name",
              "required": false
            },
            {
              "paramType": "form",
              "name": "last_name",
              "type": "string",
              "description": "Last name",
              "required": false
            },
            {
              "paramType": "form",
              "name": "email",
              "type": "string",
              "description": "Email address",
              "required": false
            },
            {
              "paramType": "form",
              "name": "tag",
              "type": "Tag",
              "description": "Tag object",
              "required": true
            }
          ],
          "responseMessages": [
            {
              "code": 401,
              "message": "Unauthorized"
            },
            {
              "code": 404,
              "message": "Not Found"
            },
            {
              "code": 406,
              "message": "Not Acceptable"
            }
          ],
          "method": "put",
          "nickname": "Api::V1::Users#update"
        }
      ]
    },
    {
      "path": "/users/{id}",
      "operations": [
        {
          "summary": "Deletes an existing User item",
          "parameters": [
            {
              "paramType": "path",
              "name": "id",
              "type": "integer",
              "description": "User Id",
              "required": false
            }
          ],
          "responseMessages": [
            {
              "code": 401,
              "message": "Unauthorized"
            },
            {
              "code": 404,
              "message": "Not Found"
            }
          ],
          "method": "delete",
          "nickname": "Api::V1::Users#destroy"
        }
      ]
    }
  ],
  "models": {
    "Tag": {
      "id": "Tag",
      "required": [
        "id"
      ],
      "properties": {
        "id": {
          "type": "integer",
          "description": "User Id"
        },
        "name": {
          "type": "string",
          "description": "Name",
          "foo": "test"
        }
      },
      "description": "A Tag object."
    }
  }
}
```

## Thanks to our contributors

Thanks to @jdar and all our contributors.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
