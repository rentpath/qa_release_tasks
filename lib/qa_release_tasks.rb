$:.unshift File.join(File.dirname(__FILE__))
require 'cli'
require 'git/commands'
require 'git/release_notes'
require 'git/tagger'
require 'git/wiki'
require 'tasks/qa_release'
require 'qa'

module QaReleaseTasks
  VERSION = '1.4.0a'

  def self.version
    VERSION
  end
end
