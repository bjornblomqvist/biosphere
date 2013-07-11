require 'biosphere/json'

class Array
  def as_json
    self
  end

  def to_json
    Biosphere::JSON.dump self.map(&:as_json)
  end
end

class OpenStruct
  def as_json
    self.to_hash.as_json
  end

  def to_json
    Biosphere::JSON.dump as_json
  end
end

class Hash
  def as_json
    self.deep_stringify_keys
  end

  def to_json
    Biosphere::JSON.dump as_json
  end
end

class NilClass
  def as_json
    self
  end

  def to_json
    { 'status' => nil }.to_json
  end
end

class String
  def as_json
    self
  end

  def to_json
    { 'status' => self }.to_json
  end
end

class Symbol
  def as_json
    self.to_s
  end

  def to_json
    as_json.to_json
  end
end
