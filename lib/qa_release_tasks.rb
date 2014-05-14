$:.unshift File.join(File.dirname(__FILE__))
require 'cli'
require 'git/commands'
require 'git/release_notes'
require 'git/tagger'
require 'git/wiki'
require 'qa_release_tasks/version'

if defined?(Rails)
  require 'qa_release_tasks/railtie'
else
  require 'qa_release_tasks/tasks/qa_release'
end

module QaReleaseTasks
  def self.version
    VERSION
  end
end
