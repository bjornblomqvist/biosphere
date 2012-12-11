# This will, obviously, be replaced by some original JSON library.
# I just needed a quick way to convert to JSON without RubyGems in Ruby 1.8.

class NilClass
  def to_json
    "null"
  end
end

class Symbol
  def to_json
    to_s.to_json
  end
end

class String
  def to_json
    inspect
  end
end

class Array
  def to_json
    '[' + map(&:to_json).join(', ') + ']'
  end
end

class Hash
  def to_json
    members = each.map { |key, value| %{#{key.to_json}:#{value.to_json}} }
    '{' + members.join(', ') + '}'
  end
end