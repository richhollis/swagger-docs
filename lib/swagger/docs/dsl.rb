module Swagger
  module Docs
    class SwaggerDSL
      # http://stackoverflow.com/questions/5851127/change-the-context-binding-inside-a-block-in-ruby/5851325#5851325
      def self.call(action, caller, &blk)
        # Create a new CommandDSL instance, and instance_eval the block to it
        instance = new
        instance.instance_eval(&blk)
        # Now return all of the set instance variables as a Hash
        instance.instance_variables.inject({}) { |result_hash, instance_variable|
          result_hash[instance_variable] = instance.instance_variable_get(instance_variable)
          result_hash # Gotta have the block return the result_hash
        }
      end

      def summary(text)
        @summary = text
      end

      def method(method)
        @method = method
      end

      def type(type)
        @type = type
      end

      def nickname(nickname)
        @nickname = nickname
      end

      def parameters
        @parameters ||= []
      end

      def param(param_type, name, type, required, description = nil, hash={})
        parameters << {:param_type => param_type, :name => name, :type => type,
          :description => description, :required => required == :required ? true : false}.merge(hash)
      end

      def response_messages
        @response_messages ||= []
      end

      def response(status, text = nil, model = nil)
        if status.is_a? Symbol
          status_code = Rack::Utils.status_code(status)
          response_messages << {:code => status_code, :message => text || status.to_s.titleize}
        else
          response_messages << {:code => status, :message => text}
        end
        response_messages.sort_by!{|i| i[:code]}
      end
    end
  end
end