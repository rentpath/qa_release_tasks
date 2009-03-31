module Git
  class ReleaseNotes
    require 'enumerator'
    include CLI
    include Commands

    def annotate!
      tags = get_tags.reverse

      start_tag = ask "Start at which tag?", tags[0], tags
      end_tag = ask "End at which tag?", tags[1] || tags[0], tags
      end_index = tags.index(end_tag) + 1 # include end tag
      start_index = tags.index(start_tag)
      tags_to_log = tags[start_index..end_index]

      puts      
      if tags_to_log.size == 1
        tag = tags_to_log.first
        print_tag_header(tag)
        puts tag_log(tag)
      else
        tags_to_log.each_cons(2) do |start, finish|
          log = tag_log(finish, start)
          next if log.empty?
          print_tag_header(start)
        end
      end
      puts
    end
    
    private
    
    def print_tag_header(tag)
      puts tag
      puts "=" * tag.length
    end
    
    def tag_log(finish, start=nil)
      `git log --no-merges --pretty=format:"%h  %s" refs/tags/#{finish}#{'..refs/tags/' + start if start}`.strip
    end
  end
end