module Git
  class Tagger
    include CLI
    include Commands

    attr_reader :options
    def initialize(options)
      @options = options
    end

    def tag!
      assert_is_git_repo
      begin
        fetch_tags
        tag_next_version(options)
        push_tags
      end
    end

    private
    
    def fetch_tags
      system("git fetch --tags")
    end

    def tag_next_version(options={})
      tag = next_version(options)
      if options[:update]
        invalid_message = "Invalid version. Version must be in the format: \"v1.2.3\""
        tag = ask "Name of new version tag ", tag, valid_version_regexp, invalid_message
      end
      system "git tag -am'Tagged by qa_release_tasks gem' #{tag}"
    end

    def push_tags
      system "git push --tags"
    end
  end
end
