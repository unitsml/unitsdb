require_relative 'base'

module Unitsdb
  module Commands
    module Validate
      class References < Base
        desc "check [INPUT]", "Validate that all references exist"
        option :debug_registry, type: :boolean, desc: "Show registry contents for debugging"
        def check(input=nil)
          files = yaml_files(input)

          # First, load all files to build a registry of valid IDs
          registry = build_id_registry(files)

          # Now check each file for references to IDs that aren't in the registry
          invalid_refs = check_references(files, registry)

          # Display results
          display_reference_results(invalid_refs, registry)
        end

        private

        def build_id_registry(files)
          registry = {}

          files.each do |file_path|
            next unless File.exist?(file_path)

            type = file_type(file_path)
            yaml = load_yaml(file_path)

            # Build registry of all available IDs
            collect_all_ids(yaml, registry, type)
          end

          # Debug registry
          if options[:debug_registry]
            puts "Registry contents:"
            registry.each do |type, ids|
              puts "  #{type}:"
              ids.each do |id, location|
                puts "    #{id} => #{location}"
              end
            end
          end

          registry
        end

        def check_references(files, registry)
          invalid_refs = {}

          files.each do |file_path|
            next unless File.exist?(file_path)

            type = file_type(file_path)
            yaml = load_yaml(file_path)

            # Check all references in this file
            check_refs_in_file(yaml, registry, invalid_refs, type)
            puts "Validated references in #{file_path}"
          end

          invalid_refs
        end

        def collect_all_ids(yaml, registry, file_type)
          registry[file_type] ||= {}

          if yaml.is_a?(Array)
            yaml.each_with_index do |item, index|
              next unless item.is_a?(Hash)

              # Collect top-level IDs
              if item.key?("identifiers") && item["identifiers"].is_a?(Array)
                item["identifiers"].each do |identifier|
                  if identifier.is_a?(Hash) && identifier.key?("id") && identifier.key?("type")
                    id = identifier["id"]
                    type = identifier["type"]
                    # Create a composite key for lookup
                    registry[file_type]["#{type}:#{id}"] = "index:#{index}:identifiers"

                    # Also store by just ID for backward compatibility or alternate formats
                    registry[file_type][id] = "index:#{index}:identifiers"
                  end
                end
              end

              # Collect other IDs (like short in dimensions)
              if item.key?("short")
                short = item["short"]
                registry["#{file_type}_short"] ||= {}
                registry["#{file_type}_short"][short] = "index:#{index}:short"
              end
            end
          else
            # Handle original hash-style structure for backward compatibility
            yaml.each do |key, value|
              next unless value.is_a?(Hash)

              if value.key?("id")
                id = value["id"]
                type = value["type"] || "default"
                registry[file_type]["#{type}:#{id}"] = key

                # Also store by just ID for backward compatibility or alternate formats
                registry[file_type][id] = key
              end

              if value.key?("short")
                short = value["short"]
                registry["#{file_type}_short"] ||= {}
                registry["#{file_type}_short"][short] = "#{key}:short"
              end
            end
          end
        end

        def check_refs_in_file(yaml, registry, invalid_refs, file_type)
          if yaml.is_a?(Array)
            yaml.each_with_index do |item, index|
              next unless item.is_a?(Hash)

              # Check references
              check_refs_in_obj(item, registry, invalid_refs, file_type, "index:#{index}")
            end
          else
            # Handle original hash-style structure
            yaml.each do |key, value|
              next unless value.is_a?(Hash)

              check_refs_in_obj(value, registry, invalid_refs, file_type, key)
            end
          end
        end

        def check_refs_in_obj(obj, registry, invalid_refs, file_type, path, prefix = "")
          case obj
          when Hash
            # Check for reference types
            reference_found = false

            # Check dimension_reference
            if obj.key?("dimension_reference")
              ref_id = obj["dimension_reference"]
              ref_type = "dimensions"
              ref_path = prefix.empty? ? "#{path}:dimension_reference" : "#{path}:#{prefix}.dimension_reference"
              reference_found = true

              validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
            end

            # Check unit_system_reference
            if obj.key?("unit_system_reference") && obj["unit_system_reference"].is_a?(Array)
              obj["unit_system_reference"].each_with_index do |ref_id, idx|
                ref_type = "unit_systems"
                ref_path = prefix.empty? ? "#{path}:unit_system_reference[#{idx}]" : "#{path}:#{prefix}.unit_system_reference[#{idx}]"
                reference_found = true

                validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
              end
            end

            # Check quantity_references
            if obj.key?("quantity_references") && obj["quantity_references"].is_a?(Array)
              obj["quantity_references"].each_with_index do |ref_id, idx|
                ref_type = "quantities"
                ref_path = prefix.empty? ? "#{path}:quantity_references[#{idx}]" : "#{path}:#{prefix}.quantity_references[#{idx}]"
                reference_found = true

                validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
              end
            end

            # Check root_units and their unit/prefix references
            if obj.key?("root_units") && obj["root_units"].is_a?(Array)
              obj["root_units"].each_with_index do |root_unit, idx|
                if root_unit.is_a?(Hash)
                  if root_unit.key?("unit_reference")
                    ref_id = root_unit["unit_reference"]
                    ref_type = "units"
                    ref_path = prefix.empty? ? "#{path}:root_units.#{idx}.unit_reference" : "#{path}:#{prefix}.root_units.#{idx}.unit_reference"
                    reference_found = true

                    validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
                  end

                  if root_unit.key?("prefix_reference")
                    ref_id = root_unit["prefix_reference"]
                    ref_type = "prefixes"
                    ref_path = prefix.empty? ? "#{path}:root_units.#{idx}.prefix_reference" : "#{path}:#{prefix}.root_units.#{idx}.prefix_reference"
                    reference_found = true

                    validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
                  end
                end
              end
            end

            # Check si_derived_bases unit/prefix references
            if obj.key?("si_derived_bases") && obj["si_derived_bases"].is_a?(Array)
              obj["si_derived_bases"].each_with_index do |base, idx|
                if base.is_a?(Hash)
                  if base.key?("unit_reference")
                    ref_id = base["unit_reference"]
                    ref_type = "units"
                    ref_path = prefix.empty? ? "#{path}:si_derived_bases.#{idx}.unit_reference" : "#{path}:#{prefix}.si_derived_bases.#{idx}.unit_reference"
                    reference_found = true

                    validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
                  end

                  if base.key?("prefix_reference")
                    ref_id = base["prefix_reference"]
                    ref_type = "prefixes"
                    ref_path = prefix.empty? ? "#{path}:si_derived_bases.#{idx}.prefix_reference" : "#{path}:#{prefix}.si_derived_bases.#{idx}.prefix_reference"
                    reference_found = true

                    validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
                  end
                end
              end
            end

            # Skip recursion for reference nodes - we've already processed them
            return if reference_found

            # Recursively process other keys
            obj.each do |k, v|
              new_prefix = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
              check_refs_in_obj(v, registry, invalid_refs, file_type, path, new_prefix)
            end
          when Array
            # Process array elements recursively
            obj.each_with_index do |item, idx|
              next unless item.is_a?(Hash) || item.is_a?(Array)

              new_prefix = prefix.empty? ? idx.to_s : "#{prefix}.#{idx}"
              check_refs_in_obj(item, registry, invalid_refs, file_type, path, new_prefix)
            end
          end
        end

        def validate_reference(ref_id, ref_type, ref_path, registry, invalid_refs, file_type)
          # Handle references that are objects with id and type
          if ref_id.is_a?(Hash) && ref_id.key?("id") && ref_id.key?("type")
            id = ref_id["id"]
            type = ref_id["type"]
            composite_key = "#{type}:#{id}"

            # Try multiple lookup strategies
            valid = false

            # 1. Try exact composite key match
            valid = true if registry.key?(ref_type) && registry[ref_type].key?(composite_key)

            # 2. Try just ID match if composite didn't work
            valid = true if !valid && registry.key?(ref_type) && registry[ref_type].key?(id)

            # 3. Try alternate ID formats for unit systems (e.g., SI_base vs si-base)
            if !valid && type == "unitsml" && ref_type == "unit_systems"
              # Special handling for unit_systems between unitsml and nist types
              valid = true if registry.key?(ref_type) && (
                registry[ref_type].keys.any? { |k| k.end_with?(":#{id}") } ||
                registry[ref_type].keys.any? { |k| k.end_with?(":SI_#{id.sub('si-', '')}") } ||
                registry[ref_type].keys.any? { |k| k.end_with?(":non-SI_#{id.sub('nonsi-', '')}") }
              )
            end

            if valid
              if options[:print_valid]
                puts "Valid reference: #{id} (#{type}) at #{file_type}:#{ref_path}"
              end
            else
              invalid_refs[file_type] ||= {}
              invalid_refs[file_type][ref_path] = { id: id, type: type, ref_type: ref_type }
            end
          else
            # Handle plain string references (legacy format)
            valid = registry.key?(ref_type) && registry[ref_type].key?(ref_id)

            if valid
              if options[:print_valid]
                puts "Valid reference: #{ref_id} (#{ref_type}) at #{file_type}:#{ref_path}"
              end
            else
              invalid_refs[file_type] ||= {}
              invalid_refs[file_type][ref_path] = { id: ref_id, type: ref_type }
            end
          end
        end

        def display_reference_results(invalid_refs, registry)
          if invalid_refs.empty?
            puts "All references are valid!"
            return
          end

          puts "\nFound invalid references:"
          invalid_refs.each do |file, refs|
            puts "  #{file}.yaml:"
            refs.each do |path, ref|
              puts "    #{path} => '#{ref[:id]}' (#{ref[:type]})"

              # Suggest corrections
              if registry.key?(ref[:type])
                similar_ids = Unitsdb::Utils.find_similar_ids(ref[:id], registry[ref[:type]].keys)
                if similar_ids.any?
                  puts "      Did you mean one of these?"
                  similar_ids.each { |id| puts "        - #{id}" }
                end
              end
            end
          end
        end
      end
    end
  end
end
