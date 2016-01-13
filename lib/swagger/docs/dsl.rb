module Swagger
  module Docs
    class SwaggerDSL
      # http://stackoverflow.com/questions/5851127/change-the-context-binding-inside-a-block-in-ruby/5851325#5851325
      def self.call(action, caller, &block)
        # Create a new SwaggerDSL instance, and instance_eval the block to it
        instance = new
        instance.instance_eval(&block)
        # Now return all of the set instance variables as a Hash
        instance.instance_variables.inject({}) { |result_hash, instance_variable|
          result_hash[instance_variable] = instance.instance_variable_get(instance_variable)
          result_hash # Gotta have the block return the result_hash
        }
      end

      def summary(text)
        @summary = text
      end

      def notes(text)
        @notes = text
      end

      def method(method)
        @method = method
      end

      def type(type)
        @type = type
      end

      def items(items)
        @items = items
      end

      def consumes(mime_types)
        @consumes = mime_types
      end

      def nickname(nickname)
        @nickname = nickname
      end

      def parameters
        @parameters ||= []
      end

      def param(param_type, name, type, required, description = nil, hash={})
        parameters << {:param_type => param_type, :name => name, :type => type,
          :description => description, :required => required == :required}.merge(hash)
      end

      # helper method to generate enums
      def param_list(param_type, name, type, required, description = nil, allowed_values = [], hash = {})
        hash.merge!({allowable_values: {value_type: "LIST", values: allowed_values}})
        param(param_type, name, type, required, description, hash)
      end

      def response_messages
        @response_messages ||= []
      end

      def response(status, text = nil, model = nil)
        if status.is_a? Symbol
          status == :ok if status == :success
          status_code = Rack::Utils.status_code(status)
          response_messages << {:code => status_code, :responseModel => model, :message => text || status.to_s.titleize}
        else
          response_messages << {:code => status, :responseModel => model, :message => text}
        end
        response_messages.sort_by!{|i| i[:code]}
      end
    end

    class SwaggerModelDSL
      attr_accessor :id

      # http://stackoverflow.com/questions/5851127/change-the-context-binding-inside-a-block-in-ruby/5851325#5851325
      def self.call(model_name, caller, &block)
        # Create a new SwaggerModelDSL instance, and instance_eval the block to it
        instance = new
        instance.instance_eval(&block)
        instance.id = model_name
        # Now return all of the set instance variables as a Hash
        instance.instance_variables.inject({}) { |result_hash, instance_var_name|
          key = instance_var_name[1..-1].to_sym  # Strip prefixed @ sign.
          result_hash[key] = instance.instance_variable_get(instance_var_name)
          result_hash # Gotta have the block return the result_hash
        }
      end

      def properties
        @properties ||= {}
      end

      def required
        @required ||= []
      end

      def description(description)
        @description = description
      end

      def property(name, type, required, description = nil, hash={})
        properties[name] = {
          type: type,
          description: description,
        }.merge!(hash)
        self.required << name if required == :required
      end
      
      # helper method to generate enums
      def property_list(name, type, required, description = nil, allowed_values = [], hash = {})
        hash.merge!({allowable_values: {value_type: "LIST", values: allowed_values}})
        property(name, type, required, description, hash)
      end
    end
  end
end
