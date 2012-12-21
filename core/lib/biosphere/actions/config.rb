require 'biosphere/action'
require 'biosphere/extensions/string'
require 'biosphere/extensions/pathname'
require 'biosphere/resources/file'
require 'ostruct'

module Biosphere
  module Errors
    class BashProfileDoesNotExist < Error
      def code() 60 end
    end
    class ZSHEnvDoesNotExist < Error
      def code() 61 end
    end
  end
end


module Biosphere
  module Actions
    # ErrorCodes: 60-65
    class Config

      Options = Class.new(OpenStruct)

      def perform(args=[])
        @args = args
        return help if Runtime.help_mode?
        if options.implode_bash_profile
          implode_bash_profile
        elsif options.implode_zshenv
          implode_zshenv
        elsif options.augment_bash_profile
          augment_bash_profile
        elsif options.augment_zshenv
          augment_zshenv
        else
          help
        end
      end

      private

      def help
        Log.info "Coming soon..."
      end

      def augment_bash_profile
        if bash_profile_path.writable?
          Resources::File.augment bash_profile_path, profile_augmentation_template('bash_profile')
        else
          message = "Cannot augment #{bash_profile_path} because the file does not exist."
          Log.error message.red
          raise Errors::BashProfileDoesNotExist, message
        end
      end

      def augment_zshenv
        if zshenv_path.writable?
          Resources::File.augment zshenv_path, profile_augmentation_template('zshenv')
        else
          message = "Cannot augment #{bash_profile_path} because the file does not exist."
          Log.error message.red
          raise Errors::ZSHEnvDoesNotExist, message
        end
      end

      def implode_bash_profile
        return unless bash_profile_path.writable?
        Log.info "Removing augmentation from #{bash_profile_path}"
        Resources::File.augment bash_profile_path
      end

      def implode_zshenv
        return unless zshenv_path.writable?
        Log.info "Removing augmentation from #{zshenv_path}"
        Resources::File.augment zshenv_path
      end

      def profile_augmentation_template(profile_name)
        profile_augmentation_path = augmentations_path.join(profile_name).unexpand_path
        result = <<-END

          # Adding the "bio" executable to your path.
          export PATH="#{core_bin_path.unexpand_path}:$PATH"

          # Loading Biosphere's bash_profile for easier de-/activation of spheres.
          [[ -s #{profile_augmentation_path} ]] && source #{profile_augmentation_path}
        END
        result.unindent
      end

      def core_bin_path
        Pathname.new BIOSPHERE_CORE_BIN_PATH
      end

      def augmentations_path
        Pathname.new BIOSPHERE_AUGMENTATIONS_PATH
      end

      def bash_profile_path
        Pathname.new('~/.bash_profile').expand_path
      end

      def zshenv_path
        Pathname.new('~/.zshenv').expand_path
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

          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Config