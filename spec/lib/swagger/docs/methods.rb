require 'spec_helper'

describe Swagger::Docs::Methods do

  describe "#swagger_actions" do
    it "merges additional configuration parameters into dsl" do
      methods = Object.new
      methods.extend(Swagger::Docs::Methods::ClassMethods)
      methods.swagger_api("test", {produces: [ "application/json" ], consumes: [ "multipart/form-data" ]}) do
      end
      expect(methods.swagger_actions()).to eq({"test"=>{:produces=>["application/json"], :consumes=>["multipart/form-data"]}})
    end
  end

end