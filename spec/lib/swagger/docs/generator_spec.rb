require 'spec_helper'

describe Swagger::Docs::Generator do

  require "fixtures/controllers/application_controller"
  require "fixtures/controllers/ignored_controller"

  before(:each) do
    FileUtils.rm_rf(tmp_dir)
    stub_const('ActionController::Base', ApplicationController)
  end

  let(:routes) {[
    stub_route("^GET$", "index", "api/v1/ignored", "/api/v1/ignored(.:format)"),
    stub_route("^GET$", "index", "api/v1/sample", "/api/v1/sample(.:format)"),
    stub_route("^GET$", "index", "api/v1/sample", "/api/v1/nested/:nested_id/sample(.:format)"),
    stub_route("^POST$", "create", "api/v1/sample", "/api/v1/sample(.:format)"),
    stub_route("^GET$", "show", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
    stub_route("^PUT$", "update", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
    stub_route("^DELETE$", "destroy", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
    stub_route("^GET$", "new", "api/v1/sample", "/api/v1/sample/new(.:format)"), # no parameters for this method
    stub_route("^GET$", "index", "", "/api/v1/empty_path") # intentional empty path should not cause any errors
  ]}

  let(:tmp_dir) { Pathname.new('/tmp/swagger-docs/') }
  let(:file_resources) { tmp_dir + 'api-docs.json' }
  let(:file_resource) { tmp_dir + 'api/v1/sample.json' }

  context "without controller base path" do
    let(:config) {
      {
        DEFAULT_VER => {:api_file_path => "#{tmp_dir}", :base_path => "http://api.no.where"}
      }
    }
    before(:each) do
      Rails.stub_chain(:application, :routes, :routes).and_return(routes)
      Swagger::Docs::Generator.set_real_methods
      require "fixtures/controllers/sample_controller"
      generate(config)
    end
    context "resources files" do
      let(:resources) { file_resources.read }
      let(:response) { JSON.parse(resources) }
      it "writes basePath correctly" do
        expect(response["basePath"]).to eq "http://api.no.where/"
      end
      it "writes apis correctly" do
        expect(response["apis"].count).to eq 1
      end
      it "writes api path correctly" do
        expect(response["apis"][0]["path"]).to eq "api/v1/sample.{format}"
      end
    end
    context "resource file" do
      let(:resource) { file_resource.read }
      let(:response) { JSON.parse(resource) }
      let(:first) { response["apis"].first }
      let(:operations) { first["operations"] }
      # {"apiVersion":"1.0","swaggerVersion":"1.2","basePath":"/api/v1","resourcePath":"/sample"
      it "writes basePath correctly" do
        expect(response["basePath"]).to eq "http://api.no.where/"
      end
      it "writes resourcePath correctly" do
        expect(response["resourcePath"]).to eq "sample"
      end
      it "writes out expected api count" do
        expect(response["apis"].count).to eq 7
      end
      context "first api" do
        #"apis":[{"path":" /sample","operations":[{"summary":"Fetches all User items"
        #,"method":"get","nickname":"Api::V1::Sample#index"}]
        it "writes path correctly" do
          expect(first["path"]).to eq "api/v1/sample"
        end
      end
    end
  end

  context "with controller base path" do
    let(:config) { Swagger::Docs::Config.register_apis({
       DEFAULT_VER => {:controller_base_path => "api/v1", :api_file_path => "#{tmp_dir}", :base_path => "http://api.no.where"}
    })}
    let(:file_resource) { tmp_dir + 'sample.json' }
    before(:each) do
      Rails.stub_chain(:application, :routes, :routes).and_return(routes)
      Swagger::Docs::Generator.set_real_methods
      require "fixtures/controllers/sample_controller"
    end

    context "test suite initialization" do
      it "the resources file does not exist" do
        expect(file_resource).to_not exist
      end
      it "the resource file does not exist" do
        expect(file_resource).to_not exist
      end
    end

    describe "#write_docs" do
      context "no apis registered" do
        before(:each) do
          Swagger::Docs::Config.register_apis({})
        end
        it "generates using default config" do
          results = generate({})
          expect(results[DEFAULT_VER][:processed].count).to eq 1
        end
      end
      before(:each) do
        generate(config)
      end
      it "cleans json files in directory when set" do
        file_to_delete = Pathname.new(File.join(config['1.0'][:api_file_path], 'delete_me.json'))
        File.open(file_to_delete, 'w') {|f| f.write("{}") }
        expect(file_to_delete).to exist
        config[DEFAULT_VER][:clean_directory] = true
        generate(config)
        expect(file_to_delete).to_not exist
      end
      it "keeps non json files in directory when cleaning" do
        file_to_keep = Pathname.new(File.join(config['1.0'][:api_file_path], 'keep_me'))
        File.open(file_to_keep, 'w') {|f| f.write("{}") }
        config[DEFAULT_VER][:clean_directory] = true
        generate(config)
        expect(file_to_keep).to exist
      end
      it "writes the resources file" do
         expect(file_resources).to exist
      end
      it "writes the resource file" do
         expect(file_resource).to exist
      end
      it "returns results hash" do
        results = generate(config)
        expect(results[DEFAULT_VER][:processed].count).to eq 1
        expect(results[DEFAULT_VER][:skipped].count).to eq 1
      end
      it "writes pretty json files when set" do
        config[DEFAULT_VER][:formatting] = :pretty
        generate(config)
        resources = File.read file_resources
        expect(resources.scan(/\n/).length).to be > 1
      end
      context "resources files" do
        let(:resources) { file_resources.read }
        let(:response) { JSON.parse(resources) }
        it "writes version correctly" do
          expect(response["apiVersion"]).to eq DEFAULT_VER
        end
        it "writes swaggerVersion correctly" do
          expect(response["swaggerVersion"]).to eq "1.2"
        end
        it "writes basePath correctly" do
          expect(response["basePath"]).to eq "http://api.no.where/api/v1/"
        end
        it "writes apis correctly" do
          expect(response["apis"].count).to eq 1
        end
        it "writes api path correctly" do
          expect(response["apis"][0]["path"]).to eq "sample.{format}"
        end
        it "writes api description correctly" do
          expect(response["apis"][0]["description"]).to eq "User Management"
        end
      end
      context "resource file" do
        let(:resource) { file_resource.read }
        let(:response) { JSON.parse(resource) }
        let(:apis) { response["apis"] }
        # {"apiVersion":"1.0","swaggerVersion":"1.2","basePath":"/api/v1","resourcePath":"/sample"
        it "writes version correctly" do
          expect(response["apiVersion"]).to eq DEFAULT_VER
        end
        it "writes swaggerVersion correctly" do
          expect(response["swaggerVersion"]).to eq "1.2"
        end
        it "writes basePath correctly" do
          expect(response["basePath"]).to eq "http://api.no.where/api/v1/"
        end
        it "writes resourcePath correctly" do
          expect(response["resourcePath"]).to eq "sample"
        end
        it "writes out expected api count" do
          expect(response["apis"].count).to eq 7
        end
        context "apis" do
          context "index" do
            let(:api) { get_api_operation(apis, "sample", :get) }
            let(:operations) { get_api_operations(apis, "sample") }
            #"apis":[{"path":" /sample","operations":[{"summary":"Fetches all User items"
            #,"method":"get","nickname":"Api::V1::Sample#index"}]
            it "writes path correctly when api extension type is not set" do
              expect(apis.first["path"]).to eq "sample"
            end
            it "writes path correctly when api extension type is set" do
              config[DEFAULT_VER][:api_extension_type] = :json
              generate(config)
              expect(apis.first["path"]).to eq "sample.json"
            end
            it "writes summary correctly" do
              expect(operations.first["summary"]).to eq "Fetches all User items"
            end
            it "writes method correctly" do
              expect(operations.first["method"]).to eq "get"
            end
            it "writes nickname correctly" do
              expect(operations.first["nickname"]).to eq "Api::V1::Sample#index"
            end
            #"parameters"=>[
            # {"paramType"=>"query", "name"=>"page", "type"=>"integer", "description"=>"Page number", "required"=>false},
            # {"paramType"=>"path", "name"=>"nested_id", "type"=>"integer", "description"=>"Team Id", "required"=>false}], "responseMessages"=>[{"code"=>401, "message"=>"Unauthorized"}, {"code"=>406, "message"=>"The request you made is not acceptable"}, {"code"=>416, "message"=>"Requested Range Not Satisfiable"}], "method"=>"get", "nickname"=>"Api::V1::Sample#index"}
            #]
            context "parameters" do
              let(:params) { operations.first["parameters"] }
              it "has correct count" do
                expect(params.count).to eq 1
              end
              it "writes paramType correctly" do
                expect(params.first["paramType"]).to eq "query"
              end
              it "writes name correctly" do
                expect(params.first["name"]).to eq "page"
              end
              it "writes type correctly" do
                expect(params.first["type"]).to eq "integer"
              end
              it "writes description correctly" do
                expect(params.first["description"]).to eq "Page number"
              end
              it "writes required correctly" do
                expect(params.first["required"]).to be_false
              end
            end
            #"responseMessages":[{"code":401,"message":"Unauthorized"},{"code":406,"message":"Not Acceptable"},{"code":416,"message":"Requested Range Not Satisfiable"}]
            context "response messages" do
              let(:response_msgs) { operations.first["responseMessages"] }
              it "has correct count" do
                expect(response_msgs.count).to eq 3
              end
              it "writes code correctly" do
                expect(response_msgs.first["code"]).to eq 401
              end
              it "writes message correctly" do
                expect(response_msgs.first["message"]).to eq "Unauthorized"
              end
              it "writes specified message correctly" do
                expect(response_msgs[1]["message"]).to eq "The request you made is not acceptable"
              end
            end
          end
          context "show" do
            let(:api) { get_api_operation(apis, "nested/{nested_id}/sample", :get) }
            let(:operations) { get_api_operations(apis, "nested/{nested_id}/sample") }
            context "parameters" do
              it "has correct count" do
                expect(api["parameters"].count).to eq 2
              end
            end
          end
          context "create" do
            let(:api) { get_api_operation(apis, "sample", :post) }
            it "writes list parameter values correctly" do
              expected_param = {"valueType"=>"LIST", "values"=>["admin", "superadmin", "user"]}
              expect(get_api_parameter(api, "role")["allowableValues"]).to eq expected_param
            end
          end
          context "update" do
            let(:api) { get_api_operation(apis, "sample/{id}", :put) }
            it "writes model param correctly" do
              expected_param = {
                "paramType" => "form",
                "name" => "tag",
                "type" => "Tag",
                "description" => "Tag object",
                "required" => true,
              }
              expect(get_api_parameter(api, "tag")).to eq expected_param
            end
          end
        end
        context "models" do
          let(:models) { response["models"] }
          # Based on https://github.com/wordnik/swagger-core/wiki/Datatypes
          it "writes model correctly" do
            expected_model = {
              "id" => "Tag",
              "required" => ["id"],
              "description" => "A Tag object.",
              "properties" => {
                "name" => {
                  "type" => "string",
                  "description" => "Name",
                  "foo" => "test",
                },
                "id" => {
                  "type" => "integer",
                  "description" => "User Id",
                }
              }
            }
            expect(models['Tag']).to eq expected_model
          end
        end
      end
    end
  end
end
