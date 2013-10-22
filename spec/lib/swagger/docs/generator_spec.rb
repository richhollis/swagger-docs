require 'spec_helper'

describe Swagger::Docs::Generator do

  require "fixtures/controllers/application_controller"
  require "fixtures/controllers/ignored_controller"

  def stub_route(verb, action, controller, spec)
    double("route", :verb => double("verb", :source => verb),
                  :defaults => {:action => action, :controller => controller},
                  :path => double("path", :spec => spec)
    )
  end

  before(:each) do
    FileUtils.rm_rf(TMP_DIR)
    routes = [
      stub_route("^GET$", "index", "api/v1/ignored", "/api/v1/ignored(.:format)"),
      stub_route("^GET$", "index", "api/v1/sample", "/api/v1/sample(.:format)"),
      stub_route("^POST$", "create", "api/v1/sample", "/api/v1/sample(.:format)"),
      stub_route("^GET$", "show", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
      stub_route("^PUT$", "update", "api/v1/sample", "/api/v1/sample/:id(.:format)"),
      stub_route("^DELETE$", "destroy", "api/v1/sample", "/api/v1/sample/:id(.:format)")
    ]
    @config = Swagger::Docs::Config.register_apis({
      "1.0" => {:controller_base_path => "api/v1", :api_file_path => "#{TMP_DIR}api/v1/"}
    })
    Rails.stub_chain(:application, :routes, :routes).and_return(routes)
    Swagger::Docs::Generator.set_real_methods
    require "fixtures/controllers/sample_controller"
  end

  context "test suite initialization" do
    it "the resources file does not exist" do
      expect(File.exists?(FILE_RESOURCES)).to be_false
    end
    it "the resource file does not exist" do
      expect(File.exists?(FILE_RESOURCE)).to be_false
    end
  end

  describe "#write_docs" do
    let(:generate) { Swagger::Docs::Generator::write_docs(@config) }
    before(:each) do
      generate
    end
    it "writes the resources file" do
      expect(File.exists?(FILE_RESOURCES)).to be_true
    end
    it "writes the resource file" do
      expect(File.exists?(FILE_RESOURCE)).to be_true
    end
    it "returns results hash" do
      results = generate
      expect(results["1.0"][:processed].count).to eq 1
      expect(results["1.0"][:skipped].count).to eq 1
    end
    context "resources files" do
      let(:resources) { File.read(FILE_RESOURCES)}
      let(:response) { JSON.parse(resources) }
      it "writes version correctly" do
        expect(response["apiVersion"]).to eq "1.0"
      end
      it "writes swaggerVersion correctly" do
        expect(response["swaggerVersion"]).to eq "1.2"
      end
      it "writes basePath correctly" do
        expect(response["basePath"]).to eq "/api/v1"
      end
      it "writes apis correctly" do
        expect(response["apis"].count).to eq 1
      end
      it "writes api path correctly" do
        expect(response["apis"][0]["path"]).to eq "/sample.{format}"
      end
      it "writes api description correctly" do
        expect(response["apis"][0]["description"]).to eq "User Management"
      end
    end
    context "resource file" do
      let(:resource) { File.read(FILE_RESOURCE)}
      let(:response) { JSON.parse(resource) }
      let(:first) { response["apis"].first }
      let(:operations) { first["operations"] }
      let(:params) { operations.first["parameters"] }
      let(:response_msgs) { operations.first["responseMessages"] }
      # {"apiVersion":"1.0","swaggerVersion":"1.2","basePath":"/api/v1","resourcePath":"/sample"
      it "writes version correctly" do
        expect(response["apiVersion"]).to eq "1.0"
      end
      it "writes swaggerVersion correctly" do
        expect(response["swaggerVersion"]).to eq "1.2"
      end
      it "writes basePath correctly" do
        expect(response["basePath"]).to eq "/api/v1"
      end
      it "writes resourcePath correctly" do
        expect(response["resourcePath"]).to eq "/sample"
      end
      it "writes out expected api count" do
        expect(response["apis"].count).to eq 5
      end
      context "first api" do
        #"apis":[{"path":" /sample","operations":[{"summary":"Fetches all User items"
        #,"method":"get","nickname":"Api::V1::Sample#index"}]
        it "writes path correctly" do
          expect(first["path"]).to eq "/sample"
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
        #"parameters":[{"paramType":"query","name":"page","type":"integer","description":"Page number","required":false}]
        context "parameters" do
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
          it "has correct count" do
            expect(response_msgs.count).to eq 3
          end
          it "writes code correctly" do
            expect(response_msgs.first["code"]).to eq 401
          end
          it "writes message correctly" do
            expect(response_msgs.first["message"]).to eq "Unauthorized"
          end
        end
      end
    end
  end
end