$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'biosphere/log'
require 'biosphere/paths'
require 'biosphere/runtime'

RSpec.configure do |config|

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true
  config.order = :random

  config.before do
    Biosphere::Runtime.env = :test
    Biosphere::Paths.biosphere_home = '/dev/null/biosphere'
  end

  config.after do
    Biosphere::Runtime.send :reset!
  end

end
