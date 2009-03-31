module Git
  class Tagger
    include CLI
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
      if options[:update]
        invalid_message = "Invalid version. Version must be in the format: \"v1.2.3\""
        tag = ask "Name of new version tag ", tag, valid_version_regexp, invalid_message
      end
      system "git tag #{tag}"
    end

    def git_push_tags
      system "git push --tags"
    end
  end
end
