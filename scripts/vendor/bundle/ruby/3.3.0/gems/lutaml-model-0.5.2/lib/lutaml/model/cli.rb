# frozen_string_literal: true

require "thor"
require "lutaml/model"

module Lutaml
  module Model
    # Command line interface for detecting duplicate records readable by Lutaml::Model
    class Cli < Thor
      #       desc "detect-duplicates PATH...",
      #            "Detect duplicate records readable by Lutaml::Model, files or directories"
      #       method_option :show_unchanged, type: :boolean, default: false,
      #                                      desc: "Show unchanged attributes in the diff output"
      #       method_option :highlight_diff, type: :boolean, default: false,
      #                                      desc: "Highlight only the differences"
      #       method_option :color, type: :string, enum: %w[auto on off], default: "auto",
      #                             desc: "Use colors in the diff output (auto, on, off)"

      #       def detect_duplicates(*paths)
      #         all_records = []
      #         paths.each do |path|
      #           if File.directory?(path)
      #             Dir.glob(File.join(path, "*.xml")).each do |file|
      #               process_file(file, all_records)
      #             end
      #           elsif File.file?(path) && path.end_with?(".xml")
      #             process_file(path, all_records)
      #           else
      #             puts "Warning: Skipping invalid path: #{path}"
      #           end
      #         end

      #         # TODO: Change using URL to a configurable primary key entered by user
      #         records_by_url = {}
      #         all_records.each do |record|
      #           urls = record[:record].location.flat_map do |loc|
      #             loc.url.map(&:content)
      #           end.compact
      #           unless urls.any?
      #             puts "Warning: Record without URL found in file: #{record[:file]}"
      #             next
      #           end

      #           urls.each do |url|
      #             records_by_url[url] ||= []
      #             records_by_url[url] << record
      #           end
      #         end

      #         duplicate_count = 0
      #         records_by_url.each do |url, records|
      #           next unless records.size > 1

      #           duplicate_count += 1
      #           puts "Duplicate set ##{duplicate_count} found for URL: #{url}"
      #           records.combination(2).each_with_index do |(record1, record2), index|
      #             puts "  Comparison #{index + 1}:"
      #             puts "  File 1: #{record1[:file]}"
      #             puts "  File 2: #{record2[:file]}"
      #             print_differences(
      #               record1[:record],
      #               record2[:record],
      #               options[:show_unchanged],
      #               options[:highlight_diff],
      #               color_enabled?,
      #             )
      #             puts "\n"
      #           end
      #         end
      #       end

      #       private

      #       def process_file(file, all_records)
      #         xml_content = File.read(file)
      #         collection = Lutaml::Model.from_xml(xml_content)
      #         collection.mods.each do |record|
      #           all_records << { record: record, file: file }
      #         end
      #       end

      #       def print_differences(record1, record2, show_unchanged, highlight_diff,
      # use_colors)
      #         diff_score, diff_tree = Lutaml::Model.diff_with_score(
      #           record1,
      #           record2,
      #           show_unchanged: show_unchanged,
      #           highlight_diff: highlight_diff,
      #           use_colors: use_colors,
      #           indent: "  ",
      #         )
      #         similarity_percentage = (1 - diff_score) * 100

      #         puts "  Differences:"
      #         puts diff_tree
      #         puts "  Similarity score: #{similarity_percentage.round(2)}%"
      #       end

      #       def color_enabled?
      #         case options[:color]
      #         when "on"
      #           true
      #         when "off"
      #           false
      #         else
      #           supports_color?
      #         end
      #       end

      #       def supports_color?
      #         return false unless $stdout.tty?

      #         if /mswin|mingw|cygwin/.match?(RbConfig::CONFIG["host_os"])
      #           return true if ENV["ANSICON"]
      #           return true if ENV["ConEmuANSI"] == "ON"
      #           return true if ENV["TERM"] == "xterm"
      #         end

      #         return true if ENV["COLORTERM"]

      #         term = ENV.fetch("TERM", nil)
      #         return false if term.nil? || term.empty?

      #         color_terms = %w[ansi color console cygwin gnome konsole kterm
      #                          linux msys putty rxvt screen tmux vt100 xterm]

      #         color_terms.any? { |ct| term.include?(ct) }
      #       end
    end
  end
end
