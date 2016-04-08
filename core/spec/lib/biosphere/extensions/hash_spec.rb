require 'spec_helper'
require 'biosphere/extensions/hash'

RSpec.describe Biosphere::Extensions::HashExtensions do

  let(:hash) { { 'one' => :two, 'three' => { 'four' => { 'five' => :six } } } }

  describe '#flatten_keys' do
    it 'flattens all keys' do
      expect(hash.flatten_keys).to eq({ "one" =>  :two, "three.four.five" => :six })
    end
  end

  describe '#flatten_keys!' do
    it 'flattens all keys destructively' do
      hash.flatten_keys!
      expect(hash).to eq({ "one" =>  :two, "three.four.five" => :six })
    end
  end

  describe '#merge_flat_key' do
    it 'merges a root key' do
      result = hash.merge_flat_key 'one', :new
      expect(result).to eq({ 'one' => :new, 'three' => { 'four' => { 'five' => :six } } })
    end

    it 'creates a new leaf key' do
      result = {}.merge_flat_key 'one.two.three', :new
      expect(result).to eq({ 'one' => { 'two' => { 'three' => :new } } })
    end

    it 'creates a new leaf key on existing node' do
      result = hash.merge_flat_key 'three.four.seven', :eight
      expect(result).to eq({ 'one' => :two, 'three' => { 'four' => { 'five' => :six, 'seven' => :eight } } })
    end

    it 'merges a leaf key' do
      result = hash.merge_flat_key 'three.four.five', :new
      expect(result).to eq({ 'one' => :two, 'three' => { 'four' => { 'five' => :new } } })
    end

    it 'merges a key' do
      result = hash.merge_flat_key 'three.four', :new
      expect(result).to eq({ 'one' => :two, 'three' => { 'four' => :new } })
    end
  end

  describe '#merge_flat_key!' do
    it 'merges a leaf key destructively' do
      hash.merge_flat_key! 'three.four.five', :new
      expect(hash).to eq({ 'one' => :two, 'three' => { 'four' => { 'five' => :new } } })
    end
  end

end
