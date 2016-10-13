path = File.expand_path(File.join(File.dirname(__FILE__), "ingreedy"))

require File.join(path, "case_insensitive_parser")
require File.join(path, "ingreedy_parser")
require File.join(path, "dictionary_collection")

module Ingreedy
  ParseFailed = Class.new(StandardError)

  class << self
    attr_accessor :locale, :preserve_amounts
  end

  def self.parse(query)
    print query
    parser = Parser.new(query)
    print parser.parse
  rescue Parslet::ParseFailed => e
    fail ParseFailed.new(e.message)
  end

  def self.dictionaries
    @dictionaries ||= DictionaryCollection.new
  end
end

Ingreedy.parse(ARGV[0])