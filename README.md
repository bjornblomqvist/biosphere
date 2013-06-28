[![Build Status](https://travis-ci.org/halo/biosphere.png?branch=master)](https://travis-ci.org/halo/biosphere)

## Introduction

Biosphere is a simple way to manage multiple development environments on your Mac. For example, if you are developing at work, privately, or for multiple customers, you might need different mysql databases, different rubies, different whatever... for each of them. We will refer to these environments as *Spheres*.

Breathe in the two beautiful design principles of Biosphere:

- The only dependency is Mac OS 10.7 (or higher).
- It is sandboxed so that you can get rid of it by removing a single directory at any time.

## Installation

The by far easiest way to install Biosphere is by using the [Biosphere Preference Pane](https://github.com/halo/BiospherePane). But let's walk through manually what the Preference Pane would do for you.

##### 1. Clone the repository from Github

I recommend the following location in your home directory:

```bash
git clone git://github.com/halo/biosphere.git ~/.biosphere
```

##### 2. Enhance your bash profile

Now we need to add something to your `~/.bash_profile` or `~/.zshenv` so that you have the `bio` executable available to you in the Terminal.

Biosphere can do that for you if you like by using the following command. The `--relative` option makes sure that the snippet inserted into your profile uses `~` to refer to your home directory.

```bash
~/.biosphere/core/bin/bio config --augment-bash-profile --relative
```

Z-shell users might want to use the following command instead. Leave out the `--relative` option, because z-shell usually has difficulties expanding `~` to an absolute path.

```bash
~/.biosphere/core/bin/bio config --augment-zshenv
```

Alternatively you can add the snippet all by yourself:

```bash
### BIOSPHERE MANAGED START ###

# Adding the "bio" executable to your path.
export PATH="~/.biosphere/core/bin:$PATH"

# Loading Biosphere's bash_profile for easier de-/activation of spheres.
[[ -s ~/.biosphere/augmentations/bash_profile ]] && source ~/.biosphere/augmentations/bash_profile

### BIOSPHERE MANAGED STOP ###
```

Note that this won't have to change in the future. You can commit this into your dotfiles.

Congratulations, now you're ready to use Biosphere!

## First steps

##### Creating Spheres

First of all you need some Spheres. Let's create a new Sphere called *work*:

```bash
bio sphere create work
```

This will create the directory `~/.biosphere/spheres/work`, and inside of it the configuration file `sphere.yml` (we'll get to that later) and the directory `augmentations`.

##### Bash Profile augmentations

Let's say that every time you enter your *work* Sphere, you want the following environment variable to be set:

```bash
export RUBYOPT=-Ku
```

Create the file `~/.biosphere/spheres/work/augmentations/bash_profile` and copy the export command above into that new file.

Now you can activate your Sphere by running this command in your Terminal:

```bash
bio activate work
```

Reload your Terminal (that is, open a new tab or run `source ~/.bash_profile`) and you will notice that the environment variable `RUBYOPT` is properly set like you want it to in that Sphere. You may also notice that Biosphere created a file called `active` inside your sphere directory to remember that the sphere is currently activated.

##### SSH config augmentations

Imagine that you would like to tweak your SSH settings for this Sphere so that whenever you SSH into a server, you want to keep the connection alive by pinging the server every 30 seconds.

Now, while the design principles of Biosphere states that it will never modify any files outside of the `~/.biosphere` directory, there is a single exception if you permit it. Let's *augment* your `~/.ssh/config` file by performing the following steps.

Create the file `~/.biosphere/spheres/work/augmentations/ssh_config` and copy the following snippet into it:

```bash
Host *
  ServerAliveInterval 30
```

##### Reactivating a Sphere

Now reactivate your sphere by typing

```bash
bio activate
```

Note that you don't have to type in the name of the sphere again. Simply `bio activate` is enough, because Biosphere remembers which Spheres are currently activated.

What just happened is that your `~/.ssh/config` file has been augmented with the following snippet:

```bash
### BIOSPHERE MANAGED START ###

# SPHERE WORK

Host *
  ServerAliveInterval 30

### BIOSPHERE MANAGED STOP ###
```

Feel free to move that snippet around within the file, yet don't break the START and STOP tags. Because when you deactivate your sphere or activate more spheres, Biosphere will understand which section it may modify by looking for these tags.

## Managing a Sphere via Chef Solo

You will remember that there is an example `sphere.yml` file inside of the `work` Sphere we just created. You can use that file to configure that this Sphere is managed by a tool such as Opscode's Chef.

Add the following content to your `sphere.yml`:

```yaml
manager:
  chefsolo:
    cookbook_path: ~/Documents/my-chef-repo/cookbooks
```

The next time you run `bio update`, Biosphere will run chef solo using the cookbooks located at `~/Documents/my-chef-repo/cookbooks`. The run list will be the recipe `biosphere`. Chef solo will have the following environment variables set so you can do things with your Sphere:

```ruby
ENV['GEM_HOME'] #=> Resources::Gem.rubygems_path
'BIOSPHERE_HOME' => BIOSPHERE_HOME, 'BIOSPHERE_SPHERE_PATH' => sphere.path, 'BIOSPHERE_SPHERE_AUGMENTATIONS_PATH' => sphere.augmentations_path }
```



You can modify all settings and even pass environment variables to the recipes. Consider the following `sphere.yml` configuration:

```yaml
manager:
  chefsolo:
    cookbook_path: ~/Code/Projects/biosphere/cortana/cookbooks
    node_name: bobs-macbook
    env_vars:
      ssh_key_name: red.github.halo
```

This will run chef solo using a custom node name and the following environment variable


#### To be continued...

Pchew, I will add more to this readme soon :)

## TODO

* Assistant for generating SSH key pairs

## Uninstallation

If you happened to have Spheres with augmentations for your SSH config file, you should first run `bio implode` so that your `~/.ssh/config` file is cleaned from any modifications made by Biosphere. You can also perform this step manually by deleting everything between the `### BIOSPHERE MANAGED START ###` and `### BIOSPHERE MANAGED STOP ###` tags.

If you didn't mess around with augmentations, simply remove the Biosphere directory. By default this is `~/.biosphere`.

Lastly, you have probably added a similar snippet to your `~/.bash_profile` too when you installed Biosphere. Just remove it from there or let `bio implode` take care of that.

## Copyright

Released under MIT 2013 funkensturm. See [MIT-LICENSE](http://github.com/halo/biosphere/blob/master/MIT-LICENSE).
