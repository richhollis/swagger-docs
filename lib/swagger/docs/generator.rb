module Swagger
  module Docs
    class Generator
      class << self

        def camelize_keys_deep!(h)
          h.keys.each do |k|
            ks    = k.to_s.camelize(:lower)
            h[ks] = h.delete k
            camelize_keys_deep! h[ks] if h[ks].kind_of? Hash
            if h[ks].kind_of? Array
              h[ks].each do |a|
                next unless a.kind_of? Hash
                camelize_keys_deep! a
              end
            end
          end
        end

        def get_api_path(spec)
          path_api = trim_leading_slash(spec.to_s.gsub("(.:format)", ""))
          parts_new = []
          path_api.split("/").each do |path_part|
            part = path_part
            if part[0] == ":"
              part[0] = "{"
              part << "}"
            end
            parts_new << part
          end
          path_api = parts_new*"/"
        end

        def trim_leading_slash(str)
          return str if !str
          return str unless str[0] == '/'
          str[1..-1]
        end

        def trim_trailing_slash(str)
          return str if !str
          return str unless str[-1] == '/'
          str[0..-2]
        end

        def trim_slashes(str)
          trim_leading_slash(trim_trailing_slash(str))
        end

        #TESTME
        # removes overlap from  /api-docs/a/b/ and a/b/b/a.json
        # returns /api-docs/a/b/b/a.json
        def resource_path(path1, path2)
          overlap = ""
          
          path2.chars.each_with_index do |char, i|
            break unless path1[overlap+char]
            overlap += char
          end

          remainder = path2.dup
          remainder.slice! overlap
          squish remainder
        end
        def squish(path)
          path = path.dup
          path.gsub!(/\/+/,"/")
          path
        end

        def set_real_methods
          ApplicationController.send(:include, Methods) # replace impotent methods with live ones
        end

        def write_docs(apis)
          results = {}
          set_real_methods
          unless Config.registered_apis.empty?
            Config.registered_apis.each do |api_version,config|
              results[api_version] = write_doc(api_version, config)
            end
          else
            config = {:api_file_path => "public/", :base_path => "/"}
            puts "No swagger_docs config: Using default config #{config}"
            results["1.0"] = write_doc("1.0", config)
          end
          results
        end

        def write_doc(api_version, config)
          base_path = trim_trailing_slash(config[:base_path] || "")
          controller_base_path = trim_leading_slash(config[:controller_base_path] || "")
          api_file_path = config[:api_file_path]
          clean_directory = config[:clean_directory] || false
          results = {:processed => [], :skipped => []}

          # create output paths
          FileUtils.mkdir_p(api_file_path) # recursively create out output path
          Dir.foreach(api_file_path) {|f| fn = File.join(api_file_path, f); File.delete(fn) if !File.directory?(fn) and File.extname(fn) == '.json'} if clean_directory # clean output path

          base_path += "/#{controller_base_path}" unless controller_base_path.empty?
          header = { :api_version => api_version, :swagger_version => "1.2", :base_path => base_path + "/"}
          resources = header.merge({:apis => []})

          paths = Rails.application.routes.routes.map{|i| "#{i.defaults[:controller]}" }
          paths = paths.uniq.select{|i| i.start_with?(controller_base_path)}
          paths.each do |path|
            next if path.empty?
            klass = "#{path.to_s.camelize}Controller".constantize
            if !klass.methods.include?(:swagger_config) or !klass.swagger_config[:controller]
              results[:skipped] << path
              next
            end
            apis = []
            debased_path = trim_leading_slash(controller_base_path ? path.gsub(controller_base_path, "") : path)
            Rails.application.routes.routes.select{|i| i.defaults[:controller] == path}.each do |route|
              action = route.defaults[:action]
              verb = route.verb.source.to_s.delete('$'+'^').downcase.to_sym
              next if !operations = klass.swagger_actions[action.to_sym]
              operations = Hash[operations.map {|k, v| [k.to_s.gsub("@","").to_sym, v] }] # rename :@instance hash keys
              operations[:method] = verb
              operations[:nickname] = "#{path.camelize}##{action}"
              apis << {:path => trim_slashes(get_api_path(trim_leading_slash(route.path.spec.to_s)).gsub("#{controller_base_path}","")), :operations => [operations]}
            end
            resource_path = resource_path api_file_path, debased_path
            resource = header.merge :resource_path => resource_path, :apis => apis
            camelize_keys_deep!(resource)
            # write controller resource file
            expanded_resource_path = squish api_file_path+"#{resource_path}.json"
            FileUtils.mkdir_p File.dirname(expanded_resource_path)
            File.open(expanded_resource_path, 'w') { |file| file.write(resource.to_json) }

            # append resource to resources array (for writing out at end)
            resources[:apis] << {path: "#{debased_path}.{format}", description: klass.swagger_config[:description]}
            results[:processed] << path
          end
          # write master resource file
          camelize_keys_deep!(resources)
          File.open("#{trim_trailing_slash api_file_path}/api-docs.json", 'w') { |file| file.write(resources.to_json) }
          results
        end
      end
    end
  end
end
