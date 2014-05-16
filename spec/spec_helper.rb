require "rails"
require "swagger/docs"
require "ostruct"
require "json"
require 'pathname'

DEFAULT_VER = Swagger::Docs::Generator::DEFAULT_VER

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.color_enabled = true

  config.before(:each) do
    Swagger::Docs::Config.base_api_controller = nil # use default object
  end
end

def generate(config)
    Swagger::Docs::Generator::write_docs(config)
end

def stub_route(verb, action, controller, spec)
  double("route", :verb => double("verb", :source => verb),
    :defaults => {:action => action, :controller => controller},
    :path => double("path", :spec => spec)
  )
end

def get_api_paths(apis, path)
  apis.select{|api| api["path"] == path}
end

def get_api_operations(apis, path)
  apis = get_api_paths(apis, path)
  apis.collect{|api| api["operations"]}.flatten
end

def get_api_operation(apis, path, method)
  operations = get_api_operations(apis, path)
  operations.each{|operation| return operation if operation["method"] == method.to_s}
end

def get_api_parameter(api, name)
  api["parameters"].each{|param| return param if param["name"] == name}
end
