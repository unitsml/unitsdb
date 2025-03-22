require 'thor'
require 'yaml'
require_relative '../utils'

module Unitsdb
  module Commands
    class Base < Thor
      class_option :dir, type: :string, default: ".", aliases: "-d", desc: "Directory containing the YAML files"
      class_option :all, type: :boolean, default: false, aliases: "-a", desc: "Process all YAML files in the repository"

      protected

      def yaml_files(input=nil)
        if options[:all]
          Unitsdb::Utils::DEFAULT_YAML_FILES.map { |f| File.join(options[:dir], f) }
        elsif input
          [input]
        else
          puts "Error: INPUT file is required when not using --all"
          exit(1)
        end
      end

      def load_yaml(file_path)
        return nil unless File.exist?(file_path)

        YAML.safe_load(File.read(file_path))
      end

      def file_type(file_path)
        File.basename(file_path, ".yaml")
      end
    end
  end
end
