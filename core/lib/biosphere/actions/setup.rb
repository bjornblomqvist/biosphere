require 'biosphere/actions'
require 'biosphere/paths'
require 'biosphere/extensions/string'
require 'biosphere/extensions/pathname'
require 'biosphere/resources/file'

module Biosphere
  module Actions
    class Setup

      def initialize(args)
        @args = args
      end

      def call
        return help if Runtime.help_mode?

        Log.separator
        create_bash_profile!
        augment_bash_profile!
        warn_about_conflicting_bash_profiles
        augment_zshenv_if_available!
        Log.separator
      end

      private

      def help
        Log.separator
        Log.info { "  bio setup".bold }
        Log.separator
        Log.info { "  Allows you to setup Biosphere fundamentals." }
        Log.separator
        Log.info { "  Examples:".cyan }
        Log.separator
        Log.info { "  bio setup  ".bold + "Prepares your ~/.bash_profile for Biosphere.".cyan }
        Log.separator
        Log.info { '  Note, however, that your biosphere directory must lie within your home directory for this to work.' }
        Log.separator
      end

      def create_bash_profile!
        Resources::File.create Paths.bash_profile
      end

      def augment_bash_profile!
        augmentation = augment Paths.bash_profile, template

        if augmentation.failure?
          message = "Cannot augment #{path} because #{augmentation.status}."
          Log.error { message.red }
          raise Errors::CouldNotAugmentProfile, message
        end
      end

      def augment_zshenv_if_available!
        if Paths.zshenv.exist?
          augment_zshenv!
        else
          Log.debug { '  There is no '.yellow + Paths.zshenv.to_s.yellow.bold + ' so I think you do not use z-shell.'.yellow }
        end
      end

      def augment_zshenv!
        augmentation = augment Paths.zshenv, template
      end

      def augment(path, content)
        augmentation = path.augment(content)
        return augmentation if augmentation.failure?

        case augmentation.status
        when :already_up_to_date
          Log.info { '  Not modifying '.yellow + path.to_s.yellow.bold + ' because it already looks good.'.yellow }
        when :content_appended
          Log.info { '  Successfully appended your '.green + path.to_s.green.bold + ' to include the following code:'.green }
          Log.separator
          content.split("\n").each do |line|
            Log.info { "  #{line}".cyan }
          end
        when :content_updated
          Log.info { "  Successfully updated #{path}.".green }
        end

        augmentation
      end

      def template
        <<-END.undent
          # Adding the "bio" executable to your path. Just for your convenience.
          export PATH="#{Paths.core_bin.unexpand_path}:$PATH"

          # Loading Biosphere shell additions (for clean and simple de-/activation of spheres).
          # These lines won't change and are safe to be commited to your dotfiles if you wish.
          [[ -s #{Paths.shell_augmentation.unexpand_path} ]] && source #{Paths.shell_augmentation.unexpand_path}
        END
      end

      def warn_about_conflicting_bash_profiles
        return unless Pathname.home_path.join('.bash_profile').exist?
        return unless Pathname.home_path.join('.profile').exist?
        Log.warn { "  Biosphere detected ~/.profile".red }
        Log.warn { "  ~/.bash_profile takes precedence over ~/.profile".red }
        Log.warn { "  If your ~/.profile has any content it will have no impact".red }
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Setup
