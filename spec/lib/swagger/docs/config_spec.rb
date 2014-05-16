require 'spec_helper'

describe Swagger::Docs::Config do

  require "fixtures/controllers/application_controller"

  let(:test_controller) { Class.new }

  before(:each) do 
    stub_const('ActionController::Base', ApplicationController)
  end

  subject { Swagger::Docs::Config }

  describe "::base_api_controller" do
    it "returns ActionController::Base by default" do
      expect(subject.base_api_controller).to eq(ActionController::Base)
    end
    it "allows assignment of another class" do
      subject.base_api_controller = test_controller
      expect(subject.base_api_controller).to eq(test_controller)
    end 
  end

  describe "::base_application" do
    it "defaults to Rails.application" do
      expect(subject.base_application).to eq (Rails.application)
    end
  end

 end
