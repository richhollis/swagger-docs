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