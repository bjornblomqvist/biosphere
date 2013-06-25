$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'biosphere/log'
require 'biosphere/paths'
require 'biosphere/runtime'

RSpec.configure do |config|
  config.order = 'rand'

  config.before do
    logger = mock(:logger, :debug => nil, :separator => nil)
    Biosphere::Log.stub!(:logger).and_return logger
    Biosphere::Paths.biosphere_home = '/dev/null/biosphere'
  end

  config.after do
    Biosphere::Runtime.send :reset!
  end
end
