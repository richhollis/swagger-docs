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
          path_api = spec.to_s.gsub("(.:format)", "")
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

        def set_real_methods
          ApplicationController.send(:include, Methods) # replace impotent methods with live ones
        end

        def write_docs(apis)
          results = {}
          set_real_methods
          Config.registered_apis.each do |api_version,config|
            results[api_version] = write_doc(api_version, config)
          end
          results
        end

        def write_doc(api_version, config)
          base_path = config[:controller_base_path]
          api_file_path = config[:api_file_path]
          results = {:processed => [], :skipped => []}

          FileUtils.mkdir_p(api_file_path) # recursively create out output path
          Dir.foreach(api_file_path) {|f| fn = File.join(api_file_path, f); File.delete(fn) if !File.directory?(fn)} # clean output path

          header = { :api_version => api_version, :swagger_version => "1.2", :base_path => "/#{base_path}"}
          resources = header.merge({:apis => []})

          paths = Rails.application.routes.routes.map{|i| "#{i.defaults[:controller]}" }
          paths = paths.uniq.select{|i| i.start_with?(base_path)}
          paths.each do |path|
            klass = "#{path.to_s.camelize}Controller".constantize
            if !klass.methods.include?(:swagger_config) or !klass.swagger_config[:controller]
              results[:skipped] << path
              next
            end
            apis = []
            Rails.application.routes.routes.select{|i| i.defaults[:controller] == path}.each do |route|
              action = route.defaults[:action]
              verb = route.verb.source.to_s.delete('$'+'^').downcase.to_sym
              next if !operations = klass.swagger_actions[action.to_sym]
              operations = Hash[operations.map {|k, v| [k.to_s.gsub("@","").to_sym, v] }] # rename :@instance hash keys
              operations[:method] = verb
              operations[:nickname] = "#{path.camelize}##{action}"
              apis << {:path => get_api_path(route.path.spec).gsub("/#{base_path}",""), :operations => [operations]}
            end
            demod = "#{path.to_s.camelize}".demodulize.camelize.underscore
            resource = header.merge({:resource_path => "/#{demod}", :apis => apis})
            camelize_keys_deep!(resource)
            # write controller resource file
            File.open("#{api_file_path}#{demod}.json", 'w') { |file| file.write(resource.to_json) }
            # append resource to resources array (for writing out at end)
            resources[:apis] << {path: "/#{demod}.{format}", description: klass.swagger_config[:description]}
            results[:processed] << path
          end
          # write master resource file
          camelize_keys_deep!(resources)
          File.open("#{api_file_path}api-docs.json", 'w') { |file| file.write(resources.to_json) }
          results
        end
      end
    end
  end
end