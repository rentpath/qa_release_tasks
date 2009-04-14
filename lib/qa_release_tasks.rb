$:.unshift File.join(File.dirname(__FILE__))
require 'cli'
require 'git/commands'
require 'git/release_notes'
require 'git/tagger'
require 'tasks/qa_release'

module QaReleaseTasks
  VERSION = '0.5.3'

  def self.version
    VERSION
  end
end
