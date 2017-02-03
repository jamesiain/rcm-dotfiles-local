jamesiain dotfiles
===============

I use [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles) and
jamesiain/dotfiles-local together using [the `*.local` convention][dot-local].

[dot-local]: http://robots.thoughtbot.com/manage-team-and-personal-dotfiles-together-with-rcm

Requirements
------------

Set zsh as my login shell.

    chsh -s /bin/zsh

Install [rcm](https://github.com/mike-burns/rcm).

    brew tap thoughtbot/formulae
    brew install rcm

Install
-------

Clone onto my laptop:

    git clone git://github.com/jamesiain/dotfiles-local.git

Install:

    rcup

This will create symlinks for the config files in my home directory.

The .rcrc file in [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)
includes $(HOME)/dotfiles-local in its search path.

I can safely run `rcup` multiple times to update.

