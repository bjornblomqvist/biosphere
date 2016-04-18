$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_group 'Core' do |file|
      file.filename =~ /lib\/biosphere.rb/ ||
        file.filename =~ /lib\/biosphere\/[^\/]*.rb/
    end

    add_group 'Actions', 'lib/biosphere/actions'
    add_group 'Resources', 'lib/biosphere/resources'
    add_group 'Managers', 'lib/biosphere/managers'
    add_group 'Tools', 'lib/biosphere/tools'
    add_group 'Extensions', 'lib/biosphere/extensions'
    add_group 'Vendor', 'lib/biosphere/vendor'

    add_filter 'spec'
  end
end

require 'tmpdir'
require 'biosphere/log'
require 'biosphere/paths'
require 'biosphere/runtime'

Dir[File.expand_path('../spec/support/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

RSpec.configure do |config|

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true
  #config.order = :random

  config.before do
   # Pathname.home_path = '/dev/null/home'
    Biosphere::Runtime.env = :test
    #Biosphere::Paths.biosphere_home = '/dev/null/biosphere'
  end

  config.around :each do |example|
    Dir.mktmpdir do |home_dir|
      Dir.mktmpdir do |biosphere_home|
        Pathname.home_path = home_dir
        Biosphere::Paths.biosphere_home = biosphere_home
        example.run
      end
    end
  end

end
