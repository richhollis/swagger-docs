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
end
