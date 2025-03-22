require_relative 'base'

module Unitsdb
  module Commands
    class Normalize < Base
      desc "yaml [INPUT] [OUTPUT]", "Normalize a YAML file or all YAML files with --all"
      method_option :sort, type: :boolean, default: true, desc: "Sort keys alphabetically"

      def yaml(input=nil, output=nil)
        unless options[:all] || (input && output)
          puts "Error: INPUT and OUTPUT are required when not using --all"
          exit(1)
        end

        if options[:all]
          Unitsdb::Utils::DEFAULT_YAML_FILES.each do |file|
            path = File.join(options[:dir], file)
            next unless File.exist?(path)
            normalize_file(path, path)
            puts "Normalized #{path}"
          end
          puts "All YAML files normalized successfully!"
        end

        if input && output
          normalize_file(input, output)
          puts "Normalized YAML written to #{output}"
        end
      end

      private

      def normalize_file(input, output)
        yaml = load_yaml(input)
        yaml = Unitsdb::Utils.sort_yaml_keys(yaml) if options[:sort]
        File.write(output, yaml.to_yaml)
      end
    end
  end
end
