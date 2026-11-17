*Copied from https://github.com/rtomayko/dotfiles*

This is my HOME, including shell environment, vim
configuration, and other misc dotfiles and scripts.

Have fun.

BACKGROUND

I've received a few emails inquiring as to how this
repository is managed and how I intend for others to use
it. There's multiple techniques for keeping a home
directory under version control -- I'll try to lay out my
goals and strategy here.

First, a few things I'm not trying to accomplish: I don't
use this repository to distribute or sync my common files
between multiple machines (that's what the ~/bin/sync-home
script is for). I also don't intend to use this repository
as a source of backup -- I have a separate incremental backup
and snapshotting tool for that.

This repository exists mainly so that I can publish my
environment and misc scripts, since I often find myself
referencing them in conversations, email, IRC, blog posts,
etc. I also like having a proper annotated change history
for these files when things break.

I don't suggest using this as some kind of prefab home
environment (although that's certainly possible). Look
through the stuff and take what you find useful with copy
and paste or by copying specific files and directories
into your own home - such is the tradition of UNIX home
directories.

TECHNIQUE

My home directory is a real git work tree. The repository
data is stored in ~/.git. Some people like to keep the
actual work tree somewhere else and symlink files into
their home. I don't do that.

One issue with this approach is that 'git status' can be
overly noisy, since most files are not tracked and show up
as "other" files. I get around this by ignoring all files
that I haven't added explicitly -- this is as simple as
adding a "*" line to the ~/.git/info/exclude file.

Another issue is how best to handle machine specific or
sensitive information (usernames / passwords, API keys,
etc.) included in dotfiles. I simply do not add any files
to the repository unless they're "clean". In some cases,
that means not adding stuff that I'd otherwise like to
have tracked. For example, I'd like to publish my
~/.gitconfig file but it contains my secret github API
key.

In other cases, I've built up systems for dealing with
this issue specifically. My ~/.bashrc file is machine
generic but sources an ~/.shenv file (untracked) if it
exists. This lets me separate machine-specific and
sensitive information from stuff I want to publish. If I
can figure out how to include a ~/.gitconfig-private or
some such file into ~/.gitconfig, I'll start tracking the
non-sensitive stuff under the repository as well.

COPYING

I didn't write all of this stuff, or even most of it.
I've tried to include proper attribution and info on
distribution and licensing in each of the file's I
found elsewhere. Please contact me if you see something
not so attributed.

# tomayko.com/about
