require_relative 'base'

module Unitsdb
  module Commands
    class Uniqueness < Base
      desc "check [INPUT]", "Check for uniqueness of 'short' and 'id' fields in a YAML file"
      def check(input=nil)
        files = yaml_files(input)
        all_dups = { short: {}, id: {} }

        files.each do |file_path|
          next unless File.exist?(file_path)

          type = file_type(file_path)
          yaml = load_yaml(file_path)

          # Find duplicates
          find_duplicates(yaml, type, all_dups)
          puts "Checked #{file_path}"
        end

        # Display results
        display_results(all_dups)
      end

      private

      def find_duplicates(yaml, file_type, all_dups)
        # Find 'short' duplicates
        shorts = {}

        # Handle array-style YAML structure
        if yaml.is_a?(Array)
          yaml.each_with_index do |item, index|
            next unless item.is_a?(Hash) && item.key?("short")
            (shorts[item["short"]] ||= []) << "index:#{index}"
          end
        else
          # Handle original hash-style structure for backward compatibility
          yaml.each do |key, value|
            next unless value.is_a?(Hash) && value.key?("short")
            (shorts[value["short"]] ||= []) << key
          end
        end

        # Add to results if duplicates found
        shorts.each do |short, paths|
          next unless paths.size > 1
          (all_dups[:short][file_type] ||= {})[short] = paths
        end

        # Find 'id' duplicates
        ids = {}

        # Handle array-style YAML structure
        if yaml.is_a?(Array)
          yaml.each_with_index do |item, index|
            next unless item.is_a?(Hash)
            # For array-based YAML, collect IDs first, then add locations to avoid dupes
            collect_ids(item, ids, "index:#{index}")
          end
        else
          # Handle original hash-style structure for backward compatibility
          yaml.each do |key, value|
            next unless value.is_a?(Hash)
            collect_ids(value, ids, key)
          end
        end

        # Add duplicates to results
        ids.each do |id, paths|
          # Deduplicate paths before checking if it's a real duplicate
          unique_paths = paths.uniq
          next unless unique_paths.size > 1
          (all_dups[:id][file_type] ||= {})[id] = unique_paths
        end
      end

      def collect_ids(obj, ids_hash, context, prefix = "")
        case obj
        when Hash
          # Direct ID in this hash
          if obj.key?("id") && !prefix.include?("si_derived_bases")
            id_key = obj["id"]
            # Only add the ID if it's at the root level or not in identifiers
            # This prevents double-counting IDs in reference hierarchies
            if prefix.empty? || !prefix.include?("identifiers")
              loc = prefix.empty? ? context : "#{context}:#{prefix}"
              (ids_hash[id_key] ||= []) << loc
            end
          end

          # Special handling for identifiers array to avoid duplication
          if obj.key?("identifiers") && obj["identifiers"].is_a?(Array)
            obj["identifiers"].each_with_index do |identifier, idx|
              if identifier.is_a?(Hash) && identifier.key?("id") && identifier.key?("type")
                id_key = identifier["id"]
                loc = prefix.empty? ? "#{context}:identifiers[#{idx}]" : "#{context}:#{prefix}.identifiers[#{idx}]"
                (ids_hash[id_key] ||= []) << loc
              end
            end
          end

          # Special handling for unit_references to avoid duplications with main unit IDs
          if (obj.key?("unit_reference") || obj.key?("prefix_reference")) &&
             (prefix.include?("root_units") || prefix.include?("si_derived_bases"))
            # Don't record these as separate IDs as they're references
            return
          end

          # Recursively process other keys
          obj.each do |k, v|
            new_prefix = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
            # Skip si_derived_bases to avoid counting derived unit references
            next if k.to_s == "si_derived_bases" || new_prefix.end_with?("si_derived_bases")
            collect_ids(v, ids_hash, context, new_prefix)
          end
        when Array
          # Skip if this is inside si_derived_bases
          return if prefix == "si_derived_bases" || prefix.end_with?(".si_derived_bases")

          # Process array elements with indices
          obj.each_with_index do |item, idx|
            next unless item.is_a?(Hash) || item.is_a?(Array)

            # For reference arrays, just process the item directly
            if prefix.include?("references") || prefix.include?("_reference")
              # Don't recurse into reference arrays to avoid duplicating IDs
              next
            else
              new_prefix = prefix.empty? ? idx.to_s : "#{prefix}.#{idx}"
              collect_ids(item, ids_hash, context, new_prefix)
            end
          end
        end
      end

      def display_results(all_dups)
        [:short, :id].each do |type|
          dups = all_dups[type]
          if dups.empty?
            puts "No duplicate '#{type}' fields found."
            next
          end

          puts "\nFound duplicate '#{type}' fields:"
          dups.each do |file, items|
            puts "  #{file}.yaml:"
            items.each do |val, paths|
              puts "    '#{val}':"
              paths.each { |p| puts "      - #{p}" }
            end
          end
        end
      end
    end
  end
end
