require 'uri'
require 'rubygems/spec_fetcher'
require 'rubygems/remote_fetcher'

module Gem
  module MavenUtils
    def maven_name?(name)
      name = name.source.sub(/\^/, '') if Regexp === name
      name =~ /^mvn:/
    end

    def maven_source_uri?(source_uri)
      source_uri.scheme == "mvn" || source_uri.host == "maven" || maven_index?(source_uri)
    end

    def maven_sources
      Gem.sources.select {|x| x =~ /^mvn:/}
    end

    def maven_spec?(gemname, source_uri)
      maven_name?(gemname) && maven_source_uri?(source_uri)
    end

    def maven_index_files
      Gem.sources.select {|x| x =~ /^mvnindex:/}
    end
    
    def maven_index?(source_uri)
      source_uri.scheme == "mvnindex"
    end
  end
  
  class SpecFetcher
    alias jruby_maven_generate_spec maven_generate_spec
    def maven_generate_spec(spec)
      if data = jruby_maven_generate_spec(spec)
        return data
      else
        raise "Unable to generate maven spec for #{spec}"
      end
    end
    
    alias jruby_list list
    def list(*args)
      sources = Gem.sources
      begin
        orig_maven_index_files = maven_index_files.dup
        Gem.sources -= maven_sources
        Gem.sources -= maven_index_files
        return jruby_list(*args).update(maven_list(orig_maven_index_files))
      ensure
        Gem.sources = sources
      end
    end
    
    def parse_maven_index(raw_uri)
      uri = URI.parse(raw_uri)
      YAML::load_stream(File.open( uri.host )).inject({}) do |mem, hosts| 
        hosts.each do |host, artifacts|
          mem[host] = artifacts.collect do |artifact| 
            parts = artifact.split(":")
            [ "mvn:#{parts[0]}:#{parts[1]}", Gem::Version.new(parts[2]), 'java' ]
          end
        end
        
        mem
      end
    end
    
    def maven_list(index_files)
      data = index_files.inject({}) do |mem, var|
        mem.update parse_maven_index(var)
        mem
      end
      data
    end
  end
end