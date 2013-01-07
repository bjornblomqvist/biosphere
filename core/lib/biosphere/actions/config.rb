require 'biosphere/action'
require 'biosphere/extensions/string'
require 'biosphere/extensions/pathname'
require 'biosphere/extensions/ostruct'
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
        return help if Runtime.help_mode? || options.empty?
        Log.separator
        implode_bash_profile if options.implode_bash_profile
        implode_zshenv       if options.implode_zshenv
        augment_bash_profile if options.augment_bash_profile
        augment_zshenv       if options.augment_zshenv
        Log.separator
      end

      private

      def help
        Log.separator
        Log.info "  bio config OPTIONS".bold
        Log.separator
        Log.info "  Allows you to setup Biosphere fundamentals."
        Log.separator
        Log.info "  Examples:".cyan
        Log.separator
        Log.info "  bio config --augment-bash-profile       ".bold + "Prepares your ~/.bash_profile for Biosphere (use --augment-zshenv for ZShell).".cyan
        Log.info "  bio config --implode-bash-profile       ".bold + "Entirely removes all Biosphere related modifications from your ~/.bash_profile.".cyan
        Log.separator
      end

      def augment_bash_profile
        result = Resources::File.augment bash_profile_path, profile_augmentation_template('bash_profile')
        if result.success?
          case result.status
          when :already_up_to_date then Log.info("  Not augmenting #{bash_profile_path} because it already is augmented.".yellow)
          else
            Log.info("  Successfully augmented #{bash_profile_path}.".yellow)
          end
        else
          message = "Cannot augment #{bash_profile_path} because #{result.status}."
          Log.error message.red
          raise Errors::BashProfileDoesNotExist, message
        end
      end

      def augment_zshenv
        if zshenv_path.writable?
          Resources::File.augment zshenv_path, profile_augmentation_template('zshenv')
        else
          message = "Cannot augment #{zshenv_path} because the file does not exist."
          Log.error message.red
          raise Errors::ZSHEnvDoesNotExist, message
        end
      end

      def implode_bash_profile
        return unless bash_profile_path.writable?
        result = Resources::File.augment bash_profile_path
        if result.success?
          Log.info "  Imploded augmentation from #{bash_profile_path}".green if result.status == :content_updated
        else
          Log.info "Could nor implode augmentation from #{bash_profile_path} because #{result.status}"
        end
      end

      def implode_zshenv
        return unless zshenv_path.writable?
        result = Resources::File.augment zshenv_path
        if result.success?
          Log.info "Imploded augmentation from #{zshenv_path}" if result.status == :content_updated
        else
          Log.info "Could nor implode augmentation from #{bash_profile_path} because #{result.status}"
        end
      end

      def profile_augmentation_template(profile_name)
        profile_augmentation_path = augmentations_path.join(profile_name).unexpand_path
        result = <<-END
          # Adding the "bio" executable to your path.
          export PATH="#{core_bin_path.unexpand_path}:$PATH"

          # Loading Biosphere's bash_profile for easier de-/activation of spheres.
          [[ -s #{profile_augmentation_path} ]] && source #{profile_augmentation_path}
        END
        result.unindent.strip
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