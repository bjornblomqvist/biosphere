require 'biosphere/json'

class Array
  def to_json
    Biosphere::JSON.dump self
  end
end

class Hash
  def to_json
    Biosphere::JSON.dump self
  end
end

class NilClass
  def to_json
    { 'status' => nil }.to_json
  end
end

class String
  def to_json
    { 'status' => self }.to_json
  end
end

class Symbol
  def to_json
    self.to_s.to_json
  end
end
