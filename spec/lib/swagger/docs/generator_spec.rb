require 'spec_helper'

describe Swagger::Docs::Generator do

  require "fixtures/controllers/application_controller"
  require "fixtures/controllers/ignored_controller"

  def generate(config)
    Swagger::Docs::Generator::write_docs(config)
  end

  def stub_route(verb, action, controller, spec)
    double("route", :verb => double("verb", :source => verb),
                  :defaults => {:action => action, :controller => controller},
                  :path => double("path", :spec => spec)
    )
  end

  before(:each) do
    FileUtils.rm_rf(TMP_DIR)
  end

  let(:routes) {[
    stub_route("^GET$", "index", "api/v1/ignored", "/api/v1/ignored(.:format)"),
    stub_route("^GET$", "index", "api/v1/sample", "/api/v1/sample(.:format)"),
    stub_route("^GET$", "index", "api/v1/sample", "/api/v1/nested/:nested_id/sample(.:format)"),
    stub_route("^POST$", "create", "api/v1/sample", "/api/v1/sample(.:format)"),
    stub_route("^GET$", "show", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
    stub_route("^PUT$", "update", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
    stub_route("^DELETE$", "destroy", "api/v1/sample", "/api/v1/sample/:id(.:format)")
  ]}

  context "without controller base path" do
    let(:config) { 
      {
        DEFAULT_VER => {:api_file_path => "#{TMP_DIR}api/v1/", :base_path => "http://api.no.where"}
      }
    }
    before(:each) do
      Rails.stub_chain(:application, :routes, :routes).and_return(routes)
      Swagger::Docs::Generator.set_real_methods
      require "fixtures/controllers/sample_controller"
      generate(config)
    end
    context "resources files" do
      let(:resources) { FILE_RESOURCES.read }
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
      let(:resource) { FILE_RESOURCE.read }
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
        expect(response["apis"].count).to eq 6
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
      DEFAULT_VER => {:controller_base_path => "api/v1", :api_file_path => "#{TMP_DIR}api/v1/", :base_path => "http://api.no.where"}
    })}
    before(:each) do 
      Rails.stub_chain(:application, :routes, :routes).and_return(routes)
      Swagger::Docs::Generator.set_real_methods
      require "fixtures/controllers/sample_controller"
    end

    context "test suite initialization" do
      it "the resources file does not exist" do
        expect(FILE_RESOURCES).to_not exist
      end
      it "the resource file does not exist" do
        expect(FILE_RESOURCE).to_not exist
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
        file_to_delete = TMP_DIR+"api/v1/delete_me.json"
        File.open(file_to_delete, 'w') {|f| f.write("{}") }
        expect(file_to_delete).to exist
        config[DEFAULT_VER][:clean_directory] = true
        generate(config)
        expect(file_to_delete).to_not exist
      end
      it "keeps non json files in directory when cleaning" do
        file_to_keep = TMP_DIR+"api/v1/keep_me"
        File.open(file_to_keep, 'w') {|f| f.write("{}") }
        config[DEFAULT_VER][:clean_directory] = true
        generate(config)
        expect(file_to_keep).to exist
      end
      it "writes the resources file" do
        expect(FILE_RESOURCES).to exist
      end
      it "writes the resource file" do
        expect(FILE_RESOURCE).to exist
      end
      it "returns results hash" do
        results = generate(config)
        expect(results[DEFAULT_VER][:processed].count).to eq 1
        expect(results[DEFAULT_VER][:skipped].count).to eq 1
      end
      it "writes pretty json files when set" do
        config[DEFAULT_VER][:formatting] = :pretty
        generate(config)
        resources = File.read FILE_RESOURCES
        expect(resources.scan(/\n/).length).to be > 1
      end
      context "resources files" do
        let(:resources) { FILE_RESOURCES.read }
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
        let(:resource) { FILE_RESOURCE.read }
        let(:response) { JSON.parse(resource) }
        let(:operations) { api["operations"] }
        let(:first_params) { operations.first["parameters"] }
        let(:first_response_msgs) { operations.first["responseMessages"] }
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
          expect(response["apis"].count).to eq 6
        end
        context "first api" do
          let(:api) { response["apis"][0] }
          #"apis":[{"path":" /sample","operations":[{"summary":"Fetches all User items"
          #,"method":"get","nickname":"Api::V1::Sample#index"}]
          it "writes path correctly when api extension type is not set" do
            expect(api["path"]).to eq "sample"
          end
          it "writes path correctly when api extension type is set" do
            config[DEFAULT_VER][:api_extension_type] = :json
            generate(config)
            expect(api["path"]).to eq "sample.json"
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
            it "has correct count" do
              expect(first_params.count).to eq 2
            end
            it "writes paramType correctly" do
              expect(first_params.first["paramType"]).to eq "query"
            end
            it "writes name correctly" do
              expect(first_params.first["name"]).to eq "page"
            end
            it "writes type correctly" do
              expect(first_params.first["type"]).to eq "integer"
            end
            it "writes description correctly" do
              expect(first_params.first["description"]).to eq "Page number"
            end
            it "writes required correctly" do
              expect(first_params.first["required"]).to be_false
            end
          end
          #"responseMessages":[{"code":401,"message":"Unauthorized"},{"code":406,"message":"Not Acceptable"},{"code":416,"message":"Requested Range Not Satisfiable"}]
          context "response messages" do
            it "has correct count" do
              expect(first_response_msgs.count).to eq 3
            end
            it "writes code correctly" do
              expect(first_response_msgs.first["code"]).to eq 401
            end
            it "writes message correctly" do
              expect(first_response_msgs.first["message"]).to eq "Unauthorized"
            end
            it "writes specified message correctly" do
              expect(first_response_msgs[1]["message"]).to eq "The request you made is not acceptable"
            end
          end
        end

        context "second api (nested)" do
          let(:api) { response["apis"][1] }
          context "parameters" do
            it "has correct count" do
              expect(first_params.count).to eq 2
            end
          end
        end
      end
    end
  end
end
