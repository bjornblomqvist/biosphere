$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'biosphere/log'

RSpec.configure do |config|
  config.order = 'rand'

  config.before do
    Biosphere::Log.stub!(:logger).and_return mock(:logger, :debug => nil, :info => nil, :error => nil, :batch => nil, :separator => nil)
  end
end
