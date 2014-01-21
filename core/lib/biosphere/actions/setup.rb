require 'biosphere/action'
require 'biosphere/paths'
require 'biosphere/extensions/string'
require 'biosphere/extensions/pathname'
require 'biosphere/extensions/ostruct'
require 'biosphere/resources/file'
require 'ostruct'

module Biosphere
  module Errors
    class CouldNotAugmentProfile < Error
      def code() 60 end
    end
  end
end

module Biosphere
  module Actions
    class Setup

      Options = Class.new(OpenStruct)

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode? || options.empty?
        Log.separator
        augment(:bash_profile) if options.augment_bash_profile
        augment(:zshenv)       if options.augment_zshenv
        implode(:bash_profile) if options.implode_bash_profile
        implode(:zshenv)       if options.implode_zshenv
        Log.separator
      end

      private

      def help
        Log.separator
        Log.info "  bio setup OPTIONS".bold
        Log.separator
        Log.info "  Allows you to setup Biosphere fundamentals."
        Log.separator
        Log.info "  Examples:".cyan
        Log.separator
        Log.info "  bio setup --augment-bash-profile       ".bold + "Prepares your ~/.bash_profile for Biosphere.".cyan
        Log.info "  bio setup --augment-zshenv             ".bold + "Prepares your ~/.zshenv for Biosphere.".cyan
        Log.info "  bio setup --implode-bash-profile       ".bold + "Entirely removes all Biosphere related modifications from your ~/.bash_profile.".cyan
        Log.info "  bio setup --implode-zshenv             ".bold + "Entirely removes all Biosphere related modifications from your ~/.zshenv.".cyan
        Log.separator
        Log.info '  Add the ' + '--relative'.bold + ' flag to ensure all paths begin with ' + '~/'.bold + ' instead of ' + '/Users/yourname'.bold + '.'
        Log.info '  This is useful if you have your .bash_profile/.zshenv in revision control and share it on multiple computers.'
        Log.info '  Note, however, that your biosphere directory must lie within your home directory for this to work.'
        Log.separator
      end

      def augment(profile_name)
        path = path_for(profile_name)
        Resources::File.create path
        result = Resources::File.augment path, template(profile_name)
        if result.success?
          case result.status
          when :already_up_to_date then Log.info("  Not augmenting #{path} because it already is augmented.".yellow)
            else                        Log.info("  Successfully augmented #{path}.".green)
          end
          
          warn_about_existing_profiles(profile_name)
        else
          message = "Cannot augment #{path} because #{result.status}."
          Log.error message.red
          raise Errors::CouldNotAugmentProfile, message
        end
      end

      def implode(profile_name)
        path = path_for(profile_name)
        return unless path.writable?
        result = Resources::File.augment path
        if result.success?
          Log.info "  Imploded augmentation from #{path}".green if result.status == :content_updated
        else
          Log.info "Could nor implode augmentation from #{path} because #{result.status}"
        end
      end

      def template(profile_name, relative=false)
        executable_path = Paths.core_bin
        executable_path = executable_path.unexpand_path if options.relative
        profile_augmentation_path = Paths.augmentations.join(profile_name.to_s)
        profile_augmentation_path = profile_augmentation_path.unexpand_path if options.relative
        <<-END.undent
          # Adding the "bio" executable to your path.
          export PATH="#{executable_path}:$PATH"

          # Loading Biosphere's bash_profile for easier de-/activation of spheres.
          [[ -s #{profile_augmentation_path} ]] && source #{profile_augmentation_path}
        END
      end

      def path_for(profile_name)
        case profile_name
        when :bash_profile then Pathname.new('~/.bash_profile').expand_path
        when :zshenv       then Pathname.new('~/.zshenv').expand_path
        when :wow          then Pathname.new('/tmp/wow').expand_path
        end
      end

      def warn_about_existing_profiles(profile_name)
        if profile_name == :bash_profile && Pathname.new('~/.profile').expand_path.exist?
          Log.info("  Biosphere detected ~/.profile".red)
          Log.info("  ~/.bash_profile takes precedence over ~/.profile".red)
          Log.info("  If your ~/.profile contains any argumentation it will have NO impect on your shell.".red)
        end
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on("--augment-bash-profile") do |value|
              result[:augment_bash_profile] = value
            end

            parser.on("--augment-zshenv") do |value|
              result[:augment_zshenv] = value
            end

            parser.on("--implode-bash-profile") do |value|
              result[:implode_bash_profile] = value
            end

            parser.on("--implode-zshenv") do |value|
              result[:implode_zshenv] = value
            end

            parser.on("--relative") do |value|
              result[:relative] = value
            end

          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Setup
