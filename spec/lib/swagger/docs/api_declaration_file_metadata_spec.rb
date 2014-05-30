require 'spec_helper'

describe Swagger::Docs::ApiDeclarationFileMetadata do

  describe "#initialize" do
    it "sets the api_version property" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath")

      expect(metadata.api_version).to eq("1.0")
    end

    it "sets the path property" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath")

      expect(metadata.path).to eq("path")
    end

    it "sets the base_path property" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath")

      expect(metadata.base_path).to eq("basePath")
    end

    it "sets the controller_base_path property" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath")

      expect(metadata.controller_base_path).to eq("controllerBasePath")
    end

    it "defaults the swagger_version property to DEFAULT_SWAGGER_VERSION" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath")

      expect(metadata.swagger_version).to eq(described_class::DEFAULT_SWAGGER_VERSION)
    end

    it "allows the swagger_version property to be_overriden" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath", swagger_version: "2.0")

      expect(metadata.swagger_version).to eq("2.0")
    end


    it "defaults the camelize_model_properties property to true" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath")

      expect(metadata.camelize_model_properties).to eq(true)
    end

    it "allows the camelize_model_properties property to be overidden" do
      metadata = described_class.new("1.0", "path", "basePath", "controllerBasePath", camelize_model_properties: false)

      expect(metadata.camelize_model_properties).to eq(false)
    end
  end
end
