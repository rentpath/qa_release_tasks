require 'rake'

namespace :qa do
  namespace :release do
    desc "Create a new minor version release from master."
    task :new do
      GitTagger.new(:minor => true).tag!
    end
  
    desc "Create a new point version release from qa branch."
    task :update do
      GitTagger.new(:point => true).tag!
    end
  end
end

class GitTagger
  attr_reader :options
  def initialize(options)
    @options = options
  end
  
  def tag!
    assert_on_qa_branch
    assert_no_local_modifications
    update_qa
    tag_next_version(options)
    git_push_tags
  ensure
    system `git checkout qa_branch`
  end
  
  private
  
  #  figure out what branch the pwd's repo is on
  def get_branch
    match = Regexp.new("^# On branch (.*)").match(`git status`)
    match && match[1]
  end

  # Find all tags that match the given pattern
  def get_tags
    version_regexp = /^v\d+\.\d+\.\d+/ # e.g. v1.4.3
    %x{git tag}.split.grep(version_regexp)
  end

  def next_version(options={})
    latest_tag = get_tags.last
    return 'v0.0.1' unless latest_tag

    unless latest_tag.match /\Av\d+\.\d+\.\d+\Z/
      STDERR.puts "Warning: invalid version number"
      return latest_tag
    end

    major, minor, point = latest_tag.split('.')
    major = major[1..-1]
    if options[:major]
      major.succ!
      minor, point = '0', '0'
    elsif options[:minor]
      minor.succ!
      point = '0'
    elsif options[:point]
      point.succ!
    else
      STDERR.puts "Warning: unable to increment version number."
    end

    'v' + [major, minor, point].join('.')
  end

  def update_qa
    response = %x(
      git checkout master    &&
      git pull               &&
      git checkout qa_branch &&
      git pull               &&
      git merge master
    )
    
    unless response.include?("Fast forward")
      warn "There are outstanding changes in qa_branch that may need to be merged into master"
    end
  end

  #  based on 'git status' output, does this repo contain changes that need to be committed?
  #  optional second argument is a specific file (or directory) in the repo.
  def needs_commit?(dir = Dir.pwd, file = nil)
    rval = false
    Dir.chdir(dir) do
      status = %x{git status}
      if file.nil?
        rval = true unless status =~ /nothing to commit \(working directory clean\)|nothing added to commit but untracked files present/
        if status =~ /nothing added to commit but untracked files present/
          puts "WARNING: untracked files present in #{dir}"
          show_changed_files(status)
        end
      else
        rval = true if status =~ /^#\t.*modified:   #{file}/
      end
    end
    rval
  end

  def assert_no_local_modifications
    if needs_commit?
      STDERR.puts "You have local modifications.  Use git commit or git stash to fix that."
      exit 1
    end
  end

  def assert_on_qa_branch
    unless get_branch == 'qa_branch'
      STDERR.puts "Sorry, you have to be in the qa_branch to do a refresh."
      exit 1
    end
  end

  def tag_next_version(options={})
    tag = next_version(options)
    system "git tag #{tag}"
  end

  def git_push_tags
    system "git push --tags"
  end
  
  def warn(message)
    STDERR.puts "*" * 50
    STDERR.puts "Warning: #{message}"
    STDERR.puts "*" * 50
  end
    
end
