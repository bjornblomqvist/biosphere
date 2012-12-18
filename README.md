## Introduction

Biosphere is a simple way to manage multiple development environments on your Mac. For example, if you are developing at work, privately, and have several customer projects, you might need different mysql databases, different rubies, different whatever for each of them. We will refer to these environments as *Spheres*.

Breathe in the two beautiful design principles of Biosphere:

- The only dependency is Mac OS 10.7 (or higher).
- It is sandboxed so that you can get rid of it by removing its directory.

## Installation

The by far easiest way to install Biosphere is by using the [Biosphere Preference Pane](https://github.com/halo/BiospherePane). But let's walk through how you can achieve the same thing the Preference Pane would help you to achieve otherwise.

##### 1. Clone the repository from Github

I recommend the default location in your home directory:

```bash
git clone git://github.com/halo/biosphere.git ~/.biosphere
```

##### 2. Enhance your bash profile

Now we need to add something to your `~/.bash_profile` or `~/.zshenv` so that you have the `bio` executable available to you in the Terminal.

Biosphere can do that for you if you like by using this command (use `--augment-zshenv` if you use z-shell):

```bash
~/.biosphere/core/bin/bio config --augment-bash-profile
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

Now you're ready to use Biosphere!

## First steps

##### Creating Spheres

Well, first of all you need some Spheres. Let's create a new Sphere called *work*:

```bash
bio sphere create work
```

This will create the directory `~/.biosphere/spheres/work`, and inside of it configuration file `sphere.yml` and the directory `augmentations`.

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

Now reload your Terminal (that is, open a new tab or run `source ~/.bash_profile`) and you will notice that the environment variable RUBYOPT is properly set like you want it to in that Sphere. You'll notice that Biosphere created a file called `active` inside your sphere directory to remember that the sphere is currently activated.

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

Note that you don't have to type in the name of the sphere again, because Biosphere remembers which spheres are currently activated. What just happened is that your `~/.ssh/config` file has been augmented with the following snippet:

```bash
### BIOSPHERE MANAGED START ###

# SPHERE WORK

Host *
  ServerAliveInterval 30

### BIOSPHERE MANAGED STOP ###
```

Feel free to move that snippet around within the file, yet don't break the START and STOP tags. Because when you deactivate your sphere or activate more spheres, Biosphere will understand which section it may modify.


#### To be continued...

Pchew, I will add more to this readme soon :)


## Uninstallation

Simply remove the Biosphere directory. By default this is `~/.biosphere`.

If you happened to have Spheres with augmentations for your SSH config file, you should first run `bio deactivate` so that your `~/.ssh/config` file is cleaned from any modifications made by Biosphere. You can also perform this step manually by deleting everything between the `### BIOSPHERE MANAGED START ###` and `### BIOSPHERE MANAGED STOP ###` tags.

Lastly, you have probably added a similar snippet to your `~/.bash_profile` too when you installed Biosphere. Just remove it from there.

## Copyright

Released under MIT 2012 funkensturm. See [MIT-LICENSE](http://github.com/halo/biosphere/blob/master/MIT-LICENSE).
