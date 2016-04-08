require 'spec_helper'
require 'uri'

RSpec.describe Biosphere::Container do

  describe '.register' do
    context 'a Class' do
      it 'registers the Class without namespace' do
        klass = Class.new { extend Biosphere::Container }
        klass.register URI::FTP
        expect(klass.find(:ftp)).to eq URI::FTP
      end
    end
  end

  describe '.all' do
    context 'no registrations' do
      it 'is an empty Array' do
        klass = Class.new { extend Biosphere::Container }
        expect(klass.all).to eq []
      end
    end
  end

end
