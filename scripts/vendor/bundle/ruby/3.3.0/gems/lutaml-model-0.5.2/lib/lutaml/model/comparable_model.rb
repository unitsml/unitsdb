# frozen_string_literal: true

module Lutaml
  module Model
    # ComparableModel module provides functionality to compare and diff two objects
    # of the same class, based on their attribute values.
    module ComparableModel
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Checks if two objects are equal based on their attributes
      # @param other [Object] The object to compare with
      # @return [Boolean] True if objects are equal, false otherwise
      def eql?(other)
        other.class == self.class &&
          self.class.attributes.all? do |attr, _|
            send(attr) == other.send(attr)
          end
      end

      alias == eql?

      # Generates a hash value for the object
      # @return [Integer] The hash value
      def hash
        ([self.class] + self.class.attributes.map do |attr, _|
                          send(attr).hash
                        end).hash
      end

      # Class methods added to the class that includes ComparableModel
      module ClassMethods
        # Generates a diff tree between two objects of the same class
        # @param obj1 [Object] The first object to compare
        # @param obj2 [Object] The second object to compare
        # @param options [Hash] Options for diff generation
        # @return [String] A string representation of the diff tree
        def diff_tree
          if @obj1.nil? && @obj2.nil?
            @root_tree = Tree.new("Both objects are nil")
          elsif @obj1.nil?
            @root_tree = Tree.new("First object is nil")
            format_single_value(@obj2, @root_tree, @obj2.class.to_s)
          elsif @obj2.nil?
            @root_tree = Tree.new("Second object is nil")
            format_single_value(@obj1, @root_tree, @obj1.class.to_s)
          else
            traverse_diff do |name, type, value1, value2, is_last|
              format_attribute_diff(name, type, value1, value2, is_last)
            end
          end

          @root_tree.to_s
        end

        # Generates a diff tree and calculates a diff score between two objects of the same class
        # @param obj1 [Object] The first object to compare
        # @param obj2 [Object] The second object to compare
        # @param options [Hash] Options for diff generation
        # @return [Array<Float, String>] An array containing the normalized diff score and the diff tree
        def diff_with_score(obj1, obj2, **options)
          context = DiffContext.new(obj1, obj2, **options)
          indent = options[:indent] || ""
          [context.calculate_diff_score, context.diff_tree(indent)]
        end
      end

      class Tree
        attr_accessor :content, :children, :color

        def initialize(content, color: nil)
          @content = content
          @children = []
          @color = color
        end

        def add_child(child)
          @children << child
        end

        def to_s(indent = "", is_last = true)
          prefix = is_last ? "└── " : "├── "
          result = "#{indent}#{colorize(prefix + @content, @color)}\n"
          @children.each_with_index do |child, index|
            is_last_child = index == @children.size - 1
            child_indent = indent + (if is_last
                                       "    "
                                     else
                                       "#{colorize('│',
                                                   @color)}   "
                                     end)
            result += child.to_s(child_indent, is_last_child)
          end
          result
        end

        private

        def colorize(text, color)
          return text unless color

          color_codes = { red: 31, green: 32, blue: 34 }
          "\e[#{color_codes[color]}m#{text}\e[0m"
        end
      end

      # DiffContext handles the comparison between two objects
      class DiffContext
        attr_reader :obj1, :obj2, :show_unchanged, :highlight_diff, :use_colors
        attr_accessor :level, :tree_lines, :root_tree

        # Initializes a new DiffContext
        # @param obj1 [Object] The first object to compare
        # @param obj2 [Object] The second object to compare
        # @param options [Hash] Options for diff generation
        def initialize(obj1, obj2, **options)
          @obj1 = obj1
          @obj2 = obj2
          @show_unchanged = options.fetch(:show_unchanged, false)
          @highlight_diff = options.fetch(:highlight_diff, false)
          @use_colors = options.fetch(:use_colors, true)
          @level = 0
          @tree_lines = []
          @root_tree = Tree.new(obj1.class.to_s)
        end

        # Generates a diff tree between the two objects
        # @return [String] A string representation of the diff tree
        def diff_tree(indent = "")
          traverse_diff do |name, type, value1, value2, is_last|
            format_attribute_diff(name, type, value1, value2, is_last)
          end
          @root_tree.to_s(indent)
        end

        # Calculates the normalized diff score
        # @return [Float] The normalized diff score
        def calculate_diff_score
          total_score = 0
          total_attributes = 0
          traverse_diff do |_, _, value1, value2, _|
            total_score += calculate_attribute_score(value1, value2)
            total_attributes += 1
          end
          total_attributes.positive? ? total_score / total_attributes : 0
        end

        private

        # Applies color to text if colors are enabled
        # @param text [String] The text to color
        # @param color [Symbol] The color to apply
        # @return [String] The colored text
        def colorize(text, color)
          return text unless @use_colors

          color_codes = { red: 31, green: 32, blue: 34 }
          "\e[#{color_codes[color]}m#{text}\e[0m"
        end

        # Traverses the attributes of the objects and yields each attribute's details
        # @yield [String, Symbol, Object, Object, Boolean] Yields the name, type, value1, value2, and is_last for each attribute
        def traverse_diff
          return yield nil, nil, obj1, obj2, true if obj1.class != obj2.class

          obj1.class.attributes.each_with_index do |(name, type), index|
            yield name, type, obj1.send(name), obj2.send(name), index == obj1.class.attributes.length - 1
          end
        end

        # Generates the prefix for tree lines
        # @return [String] Prefix for tree lines
        def tree_prefix
          @tree_lines.map { |enabled| enabled ? "│   " : "    " }.join
        end

        # Formats a line in the tree structure
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @param content [String] The content to be displayed in the line
        # @return [String] Formatted tree line
        def tree_line(is_last, content)
          "#{tree_prefix}#{is_last ? '└── ' : '├── '}#{content}\n"
        end

        # Calculates the diff score for a single attribute
        # @param value1 [Object] The value of the attribute in the first object
        # @param value2 [Object] The value of the attribute in the second object
        # @return [Float] The diff score for the attribute
        def calculate_attribute_score(value1, value2)
          if value1 == value2
            0
          elsif value1.is_a?(Array) && value2.is_a?(Array)
            calculate_array_score(value1, value2)
          else
            value1.instance_of?(value2.class) ? 0.5 : 1
          end
        end

        # Calculates the diff score for array attributes
        # @param arr1 [Array] The array from the first object
        # @param arr2 [Array] The array from the second object
        # @return [Float] The diff score for the arrays
        def calculate_array_score(arr1, arr2)
          max_length = [arr1.length, arr2.length].max
          return 0.0 if max_length.zero?

          total_score = max_length.times.sum do |i|
            if i < arr1.length && i < arr2.length
              if arr1[i] == arr2[i]
                0.0
              elsif arr1[i].is_a?(ComparableModel) && arr2[i].is_a?(ComparableModel)
                DiffContext.new(arr1[i], arr2[i],
                                show_unchanged: @show_unchanged).calculate_diff_score
              else
                calculate_attribute_score(arr1[i], arr2[i])
              end
            else
              1.0
            end
          end

          total_score / max_length
        end

        # Formats a value for display in the diff output
        # @param value [Object] The value to format
        # @return [String] Formatted value
        def format_value(value)
          case value
          when nil
            "(nil)"
          when String
            "(String) \"#{value}\""
          when Array
            if value.empty?
              "(Array) 0 items"
            else
              items = value.map { |item| format_value(item) }.join(", ")
              "(Array) [#{items}]"
            end
          when Hash
            "(Hash) #{value.keys.length} keys"
          when ComparableModel
            "(#{value.class})"
          else
            "(#{value.class}) #{value}"
          end
        end

        # Formats the diff output for a single attribute
        # @param name [String] The name of the attribute
        # @param type [Symbol] The type of the attribute
        # @param value1 [Object] The value of the attribute in the first object
        # @param value2 [Object] The value of the attribute in the second object
        # @param is_last [Boolean] Whether this is the last attribute in the list
        # @return [String] Formatted diff output for the attribute
        def format_attribute_diff(name, type, value1, value2, _is_last)
          return if value1 == value2 && !@show_unchanged

          node = Tree.new("#{name} (#{obj1.class.attributes[name].collection? ? 'collection' : type_name(type)}):")
          @root_tree.add_child(node)

          if obj1.class.attributes[name].collection?
            format_collection(value1, value2, node)
          elsif value1 == value2
            format_single_value(value1, node, "")
          else
            format_value_tree(value1, value2, node, "", type_name(type))
          end
        end

        # Formats a collection (array) for diff output
        # @param array1 [Array] The first array to compare
        # @param array2 [Array] The second array to compare
        # @return [String] Formatted diff output for the collection
        def format_collection(array1, array2, parent_node)
          array2 = [] if array2.nil?
          max_length = [array1.length, array2.length].max

          if max_length.zero?
            parent_node.content += " (nil)"
            return
          end

          max_length.times do |index|
            item1 = array1[index]
            item2 = array2[index]

            next if item1 == item2 && !@show_unchanged

            prefix = if item2.nil?
                       "- "
                     else
                       (item1.nil? ? "+ " : "")
                     end
            color = if item2.nil?
                      :red
                    else
                      (item1.nil? ? :green : nil)
                    end
            type = item1&.class || item2&.class

            node = Tree.new("#{prefix}[#{index + 1}] (#{type_name(type)})",
                            color: color)
            parent_node.add_child(node)

            if item1.nil?
              format_diff_item(item2, :green, node)
            elsif item2.nil?
              format_diff_item(item1, :red, node)
            else
              format_value_tree(item1, item2, node, "")
            end
          end
        end

        # Formats a removed item in the diff output
        # @param item [Object] The removed item
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @param index [Integer] The index of the removed item
        # @return [String] Formatted output for the removed item
        def format_removed_item(item, _parent_node)
          format_diff_item(item, :red)
        end

        # Formats an added item in the diff output
        # @param item [Object] The added item
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @param index [Integer] The index of the added item
        # @return [String] Formatted output for the added item
        def format_added_item(item, _parent_node)
          format_diff_item(item, :green)
        end

        # Formats a diff item (added or removed)
        # @param item [Object] The item to format
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @param index [Integer] The index of the item
        # @param color [Symbol] The color to use for the item
        # @param prefix [String] The prefix to use for the item (+ or -)
        # @return [String] Formatted output for the diff item
        def format_diff_item(item, color, parent_node)
          if item.is_a?(ComparableModel)
            return format_comparable_mapper(item, parent_node, color)
          end

          parent_node.add_child(Tree.new(format_value(item), color: color))
        end

        # Formats the content of an object for diff output
        # @param obj [Object] The object to format
        # @return [String] Formatted content of the object
        def format_object_content(obj)
          return format_value(obj) unless obj.is_a?(ComparableModel)

          obj.class.attributes.map do |attr, _|
            "#{attr}: #{format_value(obj.send(attr))}"
          end.join("\n")
        end

        # Formats and colors the content for diff output
        # @param content [String] The content to format and color
        # @param color [Symbol] The color to apply
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @return [String] Formatted and colored content
        def format_colored_content(content, color, is_last)
          lines = content.split("\n")
          lines.map.with_index do |line, index|
            if index.zero?
              "" # Skip the first line as it's already been output
            else
              prefix = index == lines.length - 1 && is_last ? "└── " : "├── "
              tree_line(index == lines.length - 1 && is_last,
                        colorize("#{prefix}#{line}", color))
            end
          end.join
        end

        # Gets the name of a type
        # @param type [Class, Object] The type to get the name for
        # @return [String] The name of the type
        def type_name(type)
          if type.is_a?(Class)
            type.name
          elsif type.respond_to?(:type)
            type.type.name
          else
            type.class.name
          end
        end

        # Formats the attributes of an object for diff output
        # @param obj1 [Object] The first object
        # @param obj2 [Object] The second object
        # @return [String] Formatted attributes of the objects
        def format_object_attributes(obj1, obj2, parent_node)
          obj1.class.attributes.each_key do |attr|
            value1 = obj1.send(attr)
            value2 = obj2&.send(attr)

            attr_type = obj1.class.attributes[attr].collection? ? "collection" : type_name(obj1.class.attributes[attr])

            if value1 == value2
              if @show_unchanged
                format_single_value(value1, parent_node,
                                    "#{attr} (#{attr_type})")
              end
            else
              format_value_tree(value1, value2, parent_node, attr, attr_type)
            end
          end
        end

        # Formats the value tree for diff output
        # @param value1 [Object] The first value
        # @param value2 [Object] The second value
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @param label [String] The label for the value
        # @param type_info [String, nil] Additional type information
        # @return [String] Formatted value tree
        def format_value_tree(value1, value2, parent_node, label,
type_info = nil)
          return if value1 == value2 && !@show_unchanged

          if value1 == value2
            if @show_unchanged
              return format_single_value(
                value1,
                parent_node,
                "#{label}#{type_info ? " (#{type_info})" : ''}",
              )
            end

            return if @highlight_diff
          end

          case value1
          when Array
            format_collection(value1, value2, parent_node)
          when Hash
            format_hash_tree(value1, value2, parent_node)
          when ComparableModel
            format_object_attributes(value1, value2, parent_node)
          else
            node = Tree.new("#{label}#{type_info ? " (#{type_info})" : ''}:")
            parent_node.add_child(node)
            node.add_child(Tree.new("- #{format_value(value1)}", color: :red))
            node.add_child(Tree.new("+ #{format_value(value2)}", color: :green))
          end
        end

        # Formats a single value for diff output
        # @param value [Object] The value to format
        # @param is_last [Boolean] Whether this is the last item in the current level
        # @param label [String] The label for the value
        # @return [String] Formatted single value
        def format_single_value(value, parent_node, label, color = nil)
          node = Tree.new("#{label}#{label.empty? ? '' : ':'}", color: color)
          parent_node.add_child(node)

          case value
          when ComparableModel
            format_comparable_mapper(value, node, color)
          when Array
            if value.empty?
              node.add_child(Tree.new("(nil)", color: color))
            else
              format_collection(value, value, node)
            end
          else
            node.content += " #{format_value(value)}"
          end
        end

        # Formats a ComparableModel object for diff output
        # @param obj [ComparableModel] The object to format
        # @return [String] Formatted ComparableModel object
        def format_comparable_mapper(obj, parent_node, color = nil)
          obj.class.attributes.each do |attr_name, attr_type|
            attr_value = obj.send(attr_name)
            attr_node = Tree.new("#{attr_name} (#{type_name(attr_type)}):",
                                 color: color)
            parent_node.add_child(attr_node)
            if attr_value.is_a?(ComparableModel)
              format_comparable_mapper(attr_value, attr_node, color)
            else
              value_node = Tree.new(format_value(attr_value), color: color)
              attr_node.add_child(value_node)
            end
          end
        end

        # Formats a hash tree for diff output
        # @param hash1 [Hash] The first hash to compare
        # @param hash2 [Hash] The second hash to compare
        # @return [String] Formatted hash tree
        def format_hash_tree(hash1, hash2, parent_node)
          keys = (hash1.keys + hash2.keys).uniq
          keys.each do |key|
            value1 = hash1[key]
            value2 = hash2[key]

            if value1 == value2
              format_single_value(value1, parent_node, key) if @show_unchanged
            else
              format_value_tree(value1, value2, parent_node, key)
            end
          end
        end
      end
    end

    # Generates a tree representation of the object
    # @return [String] A string representation of the object's attribute tree
    def to_tree
      output = "#{self.class}\n"
      self.class.attributes.each_with_index do |(name, type), index|
        value = send(name)
        is_last = index == self.class.attributes.length - 1
        context = DiffContext.new(nil, nil, show_unchanged: false)
        formatted = context.format_value(value)
        output << context.tree_line(is_last, "#{name} (#{type}): #{formatted}")
      end
      output
    end
  end
end
