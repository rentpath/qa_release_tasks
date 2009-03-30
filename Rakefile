require 'rake'

namespace :qa do
  namespace :release do
    desc "Create a new minor version release from master."
    task :new do
      Git::Tagger.new(:minor => true, :update => true).tag!
    end

    desc "Create a new point version release from qa branch."
    task :update do
      Git::Tagger.new(:point => true).tag!
    end

    desc "Add release notes for a given tag based on commit summaries"
    task :notes do
      Git::ReleaseNotes.new.annotate!
    end
  end
end

"Start from version? [1.3.0]: "
"Not a valid version. Valid versions are:"
"End at tag? [1.3.1]: "


module Git
  module CLI
    def ask(question="What is your quest?", default="We seek the Holy Grail", answers = ["We seek the Holy Grail"])
      loop do
        valid = false
        print "#{question} [#{default}]: "
        input = STDIN.gets.chomp
        input = default if input.empty?
        if answers.include? input
          return input
        else
          puts "Invalid answer, please try again. Valid answers include:"
          puts answers
        end
      end  
    end
  end
  
  module Commands

    #  figure out what branch the pwd's repo is on
    def get_branch
      match = Regexp.new("^# On branch (.*)").match(`git status`)
      match && match[1]
    end

    # Find all version tags
    def get_tags
      version_regexp = /^v\d+\.\d+\.\d+/ # e.g. v1.4.3
      %x{git tag}.split.grep(version_regexp).sort_by{|v| v.split('.').map{|nbr| nbr[/\d+/].to_i}}
    end

    def next_version(options={})
      latest_tag = get_tags.last.strip
      return 'v0.0.1' unless latest_tag

      unless latest_tag.match /\Av\d+\.\d+\.\d+\Z/
        warn "invalid version number"
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
        warn "unable to increment version number."
      end

      'v' + [major, minor, point].join('.')
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
            warn "untracked files present in #{dir}"
            show_changed_files(status)
          end
        else
          rval = true if status =~ /^#\t.*modified:   #{file}/
        end
      end
      rval
    end

    def warn(message)
      STDERR.puts "*" * 50
      STDERR.puts "Warning: #{message}"
      STDERR.puts "*" * 50
    end

    def error(message)
      STDERR.puts "*" * 50
      STDERR.puts "Error: #{message}"
      STDERR.puts "*" * 50
      exit 1
    end
  end


  class ReleaseNotes
    require 'enumerator'
    include CLI
    include Commands

    def annotate!
      tags = get_tags.reverse

      start_tag = ask "Start at which tag?", tags[0], tags
      end_tag = ask "End at which tag?", tags[1], tags
      end_index = tags.index(end_tag) + 1 # include end tag
      start_index = tags.index(start_tag)
      puts
      
      tags[start_index..end_index].each_cons(2) do |start, finish|
        log = `git log --pretty=format:"%h  %s" refs/tags/#{finish}..refs/tags/#{start}`.strip
        next if log.empty?
        puts "#{start}"
        puts "=" * start.length
        puts log.split("\n").reject{|line| line.include?("Merge branch 'master' into qa_branch")}
        puts
      end
    end
  end

  class Tagger
    include Commands

    attr_reader :options
    def initialize(options)
      @options = options
    end

    def tag!
      assert_on_qa_branch
      assert_no_local_modifications
      update_qa if options[:update]
      tag_next_version(options)
      git_push_tags
    ensure
      system 'git checkout qa_branch' unless get_branch == 'qa_branch'
    end

    private

    def assert_no_local_modifications
      if needs_commit?
        error "You have local modifications.  Use git commit or git stash to fix that."
      end
    end

    def assert_on_qa_branch
      unless get_branch == 'qa_branch'
        error "You have to be in the qa_branch to do a release."
      end
    end

    def update_qa
      system("git checkout master")    &&
      system("git pull")               &&
      system("git checkout qa_branch") &&
      system("git pull")               &&
      response = %x(git merge master)

      unless response.include?("Fast forward") || response.include?('Already up-to-date.')
        warn "There are outstanding changes in qa_branch that may need to be merged into master"
      end
    end

    def tag_next_version(options={})
      tag = next_version(options)
      system "git tag #{tag}"
    end

    def git_push_tags
      system "git push --tags"
    end
  end
end