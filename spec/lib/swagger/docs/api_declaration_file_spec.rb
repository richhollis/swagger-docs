require "spec_helper"

describe Swagger::Docs::ApiDeclarationFile do
  describe "#generate_resource" do

    it "generates the appropriate response" do
      path = "api/v1/sample"
      apis =[
        {
          :path=>"sample/{id}",
          :operations=>[
            {
              :summary=>"Updates an existing User",
              :parameters=>[
                { :param_type=>:path, :name=>:id, :type=>:integer, :description=>"User Id", :required=>true},
                {:param_type=>:form, :name=>:first_name, :type=>:string, :description=>"First name", :required=>false},
                {:param_type=>:form, :name=>:last_name, :type=>:string, :description=>"Last name", :required=>false},
                {:param_type=>:form, :name=>:email, :type=>:string, :description=>"Email address", :required=>false},
                {:param_type=>:form, :name=>:tag, :type=>:Tag, :description=>"Tag object", :required=>true}
              ],
              :response_messages=>[
                {:code=>401, :message=>"Unauthorized"},
                {:code=>404, :message=>"Not Found"},
                {:code=>406, :message=>"Not Acceptable"}
              ],
              :notes=>"Only the given fields are updated.",
              :method=>:put,
              :nickname=>"Api::V1::Sample#update"
            }
          ]
        }
      ]

      models = {
        :Tag=>
        {
          :id=>:Tag,
          :required=>[:id],
          :properties=>
          {
            :id=>{:type=>:integer, :description=>"User Id"},
            :name=>{:type=>:string, :description=>"Name", :foo=>"test"}
          },
          :description=>"A Tag object."
        }
      }

      controller_base_path = ""

      root = {
        :api_version=>"1.0",
        :swagger_version=>"1.2",
        :base_path=>"http://api.no.where/",
        :apis=>[]
      }


      declaration = described_class.new(path, apis, models, controller_base_path, root)


      expected_response = {
        "apiVersion"=> declaration.api_version,
        "swaggerVersion"=> declaration.swagger_version,
        "basePath"=> declaration.base_path,
        "apis"=> declaration.apis,
        "resourcePath"=> declaration.resource_path,
        :models=> declaration.models,
        :resource_file_path=> declaration.resource_file_path
      }
      expect(declaration.generate_resource).to eq(expected_response)
    end
  end
end
