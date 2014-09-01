require 'spec_helper'

describe Swagger::Docs::SwaggerDSL do

  subject { described_class.new() }

  describe "#response" do
    it "adds code, responseModel and message to response_messages" do
      subject.response(:success, "Some sample text", "Tag")
      expect(subject.response_messages).to eq([{:code=>500, :responseModel=>"Tag", :message=>"Some sample text"}])
    end
  end

end

