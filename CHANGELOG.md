## 0.2.7

- Fix issue "NoMethodError: undefined method `<' for false:FalseClass" (#133) - thanks to @heaven

## 0.2.6

- swagger_controller DSL can accept a resource_path which will be used over a generated path #126 @sb8244

## 0.2.5

- Enabled option to set 'items' inside swagger_api method #99 @krakatoa

## 0.2.4

- Parent controller option for register_apis config. #123 @mskubenich

## 0.2.3

- Added property_list to SwaggerModelDSL #108 @dr-impossible

## 0.2.2

- Support multiple route methods #128 @frodrigo

## 0.2.1

- Add support for Authorizations (OAuth 2.0) - Thanks to @RKushnir #97

## 0.2.0

- Additional logging for generation failures (suggested in #81)
- Added api_file_name to config #88
- Add support for multiple base api controllers. #93
- Change success status to ok #89
- Address issue with missing slashes - remove trailing slash from base paths and add slash before api paths #117

## 0.1.9

- Adding support for multiple engines #65
- Add ability for swagger_api to accept parameters (e.g. consumes, produces)
- Update dependencies #64
- Address issue with routing verbs where some verbs do not have a route.verb.source attribute only route.verb #58
- Add ability to set custom attributes (like info block) on api-docs file #67
- Ensure API endpoint/nickname (e.g. "Api::V1::Some#update") is only written out once per resource file. Addresses PATCH, POST duplication issue #70
- Add "consumes" dsl method #74
- Expose API version on transform_path for easier “No Server Integrations” #79

## 0.1.8

- Fix issue with gem build open-ended dependency warnings in gemspec
- Fix issue where param_list doesn't output parameter description #57

## 0.1.7

- Make camelizing of model properties configurable. #55

## 0.1.6

- Document notes DSL
- Get rid of unnecessary ternary operator in dsl.rb #54
- Fix development dependencies gems requirements #53
- Add support for the `notes` property #52
- Config's base_api_controller is configurable #51

## 0.1.5
- Delay processing docs DSL to allow changing the context of the controllers #47 @ldnunes

## 0.1.4
- An undocumentated action in a documented controller should not raise errors #43 @ldnunes
- Allow reopening of docs definition for the swagger_api DSL command #44 @ldnunes
- Refactor write_docs to split the documentation generation from file writing #45 @ldnunes

## 0.1.3
- Fix issue where empty path throws error

## 0.1.2
- Add suport for Swagger models
- Use ActionControlller::Base instead of ApplicationController. fixes #27
- Status codes for response
- Path generation fixes #26 @stevschmid
- Ignore path filtering when no params are set
- Add param_list helper for generating enums/lists
- Improve structure of generator class - break up large methods
- Fix the destination path of the resource files #30

## 0.1.1
- Add support for Rails engines (@fotinakis)
- Filter out path parameters if the parameter is not in the path (@stevschmid)

## 0.1.0

- Add CHANGELOG.md
- Add `api_extension_type` option (support for other route .formats)
- Rails Appraisals
- Add configuration options table to README documentation
- Guidance on inheritance and asset pre-compilation
- Custom response message error text can now be set
- Ability to override base controller with `base_api_controller` method
- Default configuration for Generator
- Fix typo in README.md

##0.0.3

- Documentation 

## 0.0.2 

- Add `base_path` option

## 0.0.1 

- Initial release