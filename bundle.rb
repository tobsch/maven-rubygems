#!/usr/bin/env ruby
begin
  require File.expand_path('../maven_list_hack', __FILE__)
  require 'bundler'
  require 'bundler/cli'
  
  # Check if an older version of bundler is installed
  $:.each do |path|
    if path =~ %r'/bundler-0.(\d+)' && $1.to_i < 9
      err = "Please remove Bundler 0.8 versions."
      err << "This can be done by running `gem cleanup bundler`."
      abort(err)
    end
  end
  Bundler::CLI.start
rescue Bundler::BundlerError => e
  Bundler.ui.error e.message
  Bundler.ui.debug e.backtrace.join("\n")
  exit e.status_code
rescue Interrupt => e
  JrubyBundler.ui.error "\nQuitting..."
  JrubyBundler.ui.debug e.backtrace.join("\n")
  exit 1
end