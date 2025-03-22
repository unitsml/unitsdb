module Unitsdb
  module Utils
    DEFAULT_YAML_FILES = %w[dimensions prefixes quantities unit_systems units].map { |f| "#{f}.yaml" }

    def self.levenshtein_distance(s, t)
      m = s.length
      n = t.length

      return m if n == 0
      return n if m == 0

      d = Array.new(m+1) { Array.new(n+1) }

      (0..m).each { |i| d[i][0] = i }
      (0..n).each { |j| d[0][j] = j }

      (1..n).each do |j|
        (1..m).each do |i|
          d[i][j] = if s[i-1] == t[j-1]
                      d[i-1][j-1]
                    else
                      [d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + 1].min
                    end
        end
      end

      d[m][n]
    end

    def self.find_similar_ids(id, valid_ids, max_results = 5)
      # Simple similarity measure based on Levenshtein distance
      valid_ids
        .map { |valid_id| [valid_id, levenshtein_distance(id.to_s, valid_id.to_s)] }
        .sort_by { |_, distance| distance }
        .take(max_results)
        .select { |_, distance| distance < [id.to_s.length, 10].min }
        .map { |valid_id, _| valid_id }
    end

    def self.sort_yaml_keys(obj)
      case obj
      when Hash
        # Transform values first, then sort keys
        obj.transform_values { |v| sort_yaml_keys(v) }
           .sort_by do |key, _|
             key_str = key.to_s

             # Handle NIST IDs with proper category-based sorting
             if key_str =~ /\ANIST([a-z])(\d+)_(-?\d+)\Z/         # Prefixes with power (NISTp2_10)
               [0, $1, $2.to_i, $3.to_i]
             elsif key_str =~ /\ANIST([a-z])(\d+)\Z/              # Prefixes without power
               [0, $1, $2.to_i, 0]
             elsif key_str.match?(/[\/e]/)                        # Composite IDs with '/' or 'e' to the end
               [2, key_str]
             elsif key_str =~ /\ANISTu(\d+)\.(.+)\Z/              # Simple unit IDs (NISTu10.1)
               [1, 'u', $1.to_i, $2]
             else
               [3, key_str]                                       # Everything else
             end
           end.to_h
      when Array
        # For arrays in the new structure, sort them if they're arrays of hashes with 'id' or 'short' keys
        if !obj.empty? && obj.all? { |item| item.is_a?(Hash) }
          # Sort by 'id' within identifiers array
          if obj.first.key?("id") && obj.first.key?("type")
            obj.sort_by { |item| item["id"].to_s }.map { |item| sort_yaml_keys(item) }
          # Sort by 'short' for other arrays (like main unit arrays)
          elsif obj.first.key?("short")
            obj.sort_by { |item| item["short"].to_s }.map { |item| sort_yaml_keys(item) }
          else
            obj.map { |item| sort_yaml_keys(item) }
          end
        else
          obj.map { |item| sort_yaml_keys(item) }
        end
      else
        obj
      end
    end
  end
end
