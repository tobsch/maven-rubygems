# Maven/rubygems compatiblity improvements

## What is it all about?
The most annoying thing in the jRuby world is dependency handling:
As soon as you've got two gems which bundle or require the same jar, you'll run into difficulties with objects which are not compatible.

A way to cleanly handle java dependencies is maven. But maven stands on its own and has no clue of rubygems.

In jRuby 1.6.x the 
   gem install mvn:foo

magic was introduced which basically makes gems of jars.
But there is one problem left: Bundler does not support this because of the missing way to list all jars in a repository.

## How to solve this?
We must teach rubygems in jRuby to list jars.
This seems to be a missing feature in maven, so we need index files/servers for this.

## Whats the status?
The basic index just works!
It's included in the file called "testindex".
So far, installing a gem with dependencies does not work.
The next step to get it up and running would be to solve this issue.