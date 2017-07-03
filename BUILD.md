# NeboLand Arma Server Build Document

NeboLand Arma3/Exile/Zombies/Raptors is an exciting place.  Soon we will be opening up for public fun.

This server/system should be taken as a sketch to improve build systems for the Arma dedicated server 
community.  But it's also early days, I am only sketching this as far as I need to/can see.  
Please feel free to adapt and build on this work either by fork or pull request if you see something you
like and want to use.

Thanks!

-lk



## Server Assumptions

While I have made an attempt to generalize these build scripts for multiple situations, I 
am developing for my specific situation with the following assumptions:

* Windows 10 - this is also my gaming rig.
* [Ruby for Windows](https://rubyinstaller.org/)
* [git for Windows](https://git-scm.com/downloads)
* [HostHavoc](https://hosthavoc.com/) - there are many game servers, 
  as well as rolling your own, this just happens to be the one we use.  HostHavoc uses Windows servers as their base.
* [Steam](http://store.steampowered.com/) - Arma 3 and Arma 3 Tools should be installed.
* For the actual build process I attempt to use the latest official Arma 3 Tools (AddonBuilder) for pbo
  via the commandline. The famous [Mikero's DOS Tools](http://www.armaholic.com/page.php?id=19784) toolchain 
  is another alternative. Sometimes it's handy to use both.  For example, I use Eliteness to depbo files.
* I let HostHavoc own the Exile mod since there is database integration that they script and support.
* I let Steam Workshop download and update most of the other mods that I use. `steamcmd` is an alternative if you
  have access to that, or run your own server (i.e. with Linux GSM).
* A good text editor.  I prefer [Sublime Text 3](https://www.sublimetext.com/)
* A decent multi-terminal. Installing git for windows will give you a bash (mingw) shell, but do yourself a favor
  and get a decent multi-terminal to go with it.  I use [ConEmu](https://conemu.github.io/).

Most of this project should build out of the box, but you may have to comment out steps for 
infiSTAR if you don't purchase that, and possibly change the maps data.

After installing these tools, you should be able to setup by going into a workspace on your drive and
from a bash shell type:

```
$ git clone https://github.com/coldnebo/neboland.git
$ cd neboland
$ gem install bundle
$ bundle install
$ rake -T
$ cp config-example.json config.json      # and edit to your liking
```


## Overview

This server uses a two-pass build approach from source.  

* PASS1: The first pass injects values from `config.json`
  into `source/` files via the [Erubis](http://www.kuwata-lab.com/erubis/) templating engine and places the result 
  into `build/`
* PASS2: The second pass uses Arma 3 Tools to compile pbos from `build/` and produce artifacts which are placed into `stage/`

Finally, `stage/` files are deployed to a parallel structure off the server `config.ftp.basedir`.



## Structure

```
config.json              # make your own from the config-example.json included in the project.
config-example.json      # example to show where to place your private credentials, etc.
source/                  # this is where your straight files go; files that are either staged directly or preprocessed
  mods/                  # this is where your mods built from source go.
build.rake               # contains the details of building the server.
Rakefile                 # contains deploy, generate and update_mods tasks and provides general structure.
```


## Rake tasks

```
$ rake -T
rake build        # build the server
rake clean        # Remove any temporary products
rake clobber      # Remove any generated files
rake deploy       # deploy the server
rake generate     # generate command line for mods
rake update       # updates git submodules
rake update_mods  # update steam managed mods to server
```



### update_mods

This task is designed to make it easier to sync your steam workshop mods to your host via ftp.

Steps:

* ftp to your host and delete the mod folder you want to update (e.g. @CBA_A3/)
* run 'rake update_mods'.  The task will check if the target mod folder exists and if it doesn't it will 
  ftp copy the mod from your Steam Workshop folder to your server.  This task will also handle copying
  the bikey files from the mods to your source/keys folder for deployment. (NOTE: the location of your
  server keys may vary.)


NOTE: I went this way because HostHavoc doesn't provide access to the steamcmd directly (mostly for credential and
security reasons), otherwise I could have subscribed to various mods and used the steamcmd to automatically update 
these mods in place (which can be faster/more efficient than ftpping fresh copies up and deleting unneed files from the updates).

If you run your own linux server, I would recommend checking out Linux Game Server Managers (gsm) which 
has a really nice [arma3server](https://gameservermanagers.com/lgsm/arma3server/) base you can build from.


### rake generate

This task simply outputs commandline params for your mods and servermods options to Arma3 based on what you have in 
your config.json file.  Mostly just a convience.

### rake build 

Builds the server (everything ends up in `stage/`).

### rake deploy

Deploys the server (basically a deploy of everything in `stage/`).

### rake update

Updates git submodule dependencies.


## Submodule management

Dependencies on other mods like Defent's Exile Mission System (DMS) are managed via 
[git submodules](https://git-scm.com/docs/git-submodule) wherever those mods are maintained
in github.  Other dependencies are manually maintained (such as Exile) and in some cases
kept out of git altogether (such as commercial products like infiSTAR).

