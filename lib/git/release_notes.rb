module Git
  class ReleaseNotes
    require 'enumerator'
    include CLI
    include Commands

    def annotate!
      tags = get_tags.reverse
      
      start_tag = ask "Start at which tag?", tags[0], tags
      start_index = tags.index(start_tag)      
      end_tag = ask "End at which tag?", tags[start_index + 1] || tags[start_index], tags
      puts
      end_index = tags.index(end_tag) + 1 # include end tag
      
      start_index.upto(end_index-1) do |i|
        start = tags[i]
        finish = tags[i+1]
        log = `git log --no-merges --pretty=format:"%h  %s" #{'refs/tags/' + finish + '..' if finish}refs/tags/#{start}`.strip
        next if log.empty?
        puts "#{start}"
        puts "=" * start.length
        puts log
        puts
      end
    end
  end
end