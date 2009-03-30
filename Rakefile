require 'rake'

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

def upate_qa
  system <<-SH
    git checkout master    &&
    git pull --tags        &&
    git checkout qa_branch &&
    git pull               &&
    git merge master
  SH
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
  if !tag.match(tag_regexp)
    STDERR.puts "Error:  Invalid tag #{tag}, must be of the format v.X.X.X (ie: v1.3.2)"
    exit 1
  end
  system "git tag #{tag}"
end

def git_push_tags
  system "git push --tags"
end

namespace :qa do
  namespace :release do
    desc "Create a new minor version release from master."
    task :new do
      assert_on_qa_branch
      assert_no_local_modifications
      update_qa
      tag_next_version(:minor => true)
      git_push_tags
    end
  
    desc "Create a new point version release from qa branch."
    task :update do
      assert_on_qa_branch
      assert_no_local_modifications
      update_qa
      tag_next_version(:point => true)
      git_push_tags
    end
  end
end
