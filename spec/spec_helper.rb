require "rails"
require "swagger/docs"
require "ostruct"
require "json"

TMP_DIR = "/tmp/swagger-docs/"
TMP_API_DIR = "/tmp/swagger-docs/api/v1/"
FILE_RESOURCES = "#{TMP_API_DIR}api-docs.json"
FILE_RESOURCE = "#{TMP_API_DIR}sample.json"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.color_enabled = true
end
