module Lutaml
  module Model
    module Loggable
      def self.included(base)
        base.define_method :warn_auto_handling do |name|
          caller_file = File.basename(caller_locations(2, 1)[0].path)
          caller_line = caller_locations(2, 1)[0].lineno

          str = "[Lutaml::Model] WARN: `#{name}` is handled by default. No need to explecitly define at `#{caller_file}:#{caller_line}`"
          warn(str)
        end
      end
    end
  end
end
