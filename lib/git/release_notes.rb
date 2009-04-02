module Git
  class ReleaseNotes
    require 'enumerator'
    include CLI
    include Commands
    
    def initialize(options = {})
      @options = options
      @limit = options[:limit].nil? ? 20 : options[:limit]
    end

    def annotate!
      assert_is_git_repo
      tags = get_tags.reverse
      error "No version tags available." if tags.empty?
      
      start_tag = ask "Start at which tag?", tags[0], tags
      start_index = tags.index(start_tag)      
      end_tag = ask "End at which tag?", tags[start_index + 1] || tags[start_index], tags
      puts
      end_index = tags.index(end_tag) + 1 # include end tag
      
      start_index.upto(end_index-1) do |i|
        start = tags[i]
        finish = tags[i+1]
        range = ''
        range << "refs/tags/#{finish}.." if finish # log until end tag if there is an end tag
        range << "refs/tags/#{start}"
        log = `git log --no-merges --pretty=format:"%h  %s" #{range}`.strip.split("\n")
        next if log.empty?
        puts "#{start}"
        puts "=" * start.length
        puts @limit ? log[0,@limit] : log
        puts "         ... and #{log.size - @limit} more." if @limit && log.size > @limit
        puts
      end
    end
  end
end
