module Swagger
  module Docs
    module SlashTrimmer
      module_function

      def trim_leading_slashes(str)
        return str if !str
        str.gsub(/\A\/+/, '')
      end

      def trim_trailing_slashes(str)
        return str if !str
        str.gsub(/\/+\z/, '')
      end

      def trim_slashes(str)
        trim_leading_slashes(trim_trailing_slashes(str))
      end
    end
  end
end
