$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'biosphere/log'

RSpec.configure do |config|
  config.order = 'rand'

  config.before do
    logger = mock(:logger, :debug => nil, :separator => nil)
    Biosphere::Log.stub!(:logger).and_return logger
  end
end
