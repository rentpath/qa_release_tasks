module CLI
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

  def ask(question, default=nil, valid_response=nil, invalid_message=nil)
    loop do
      print "#{question}"
      print "[#{default}]" if default
      print ": "
      answer = STDIN.gets.chomp
      answer = default if default && answer.empty?
      valid = false
      valid = true if valid_response.nil?
      valid = true if valid_response.respond_to?(:include?) && valid_response.include?(answer)
      valid = true if valid_response.respond_to?(:match) && valid_response.match(answer)
      if valid
        return answer
      else
        if valid_response.is_a?(Array)
          puts invalid_message || begin
            print "Invalid answer, please try again."
            print " Valid answers include:\n"
            puts valid_response
          end
        elsif valid_response.is_a?(Regexp)
          puts invalid_message || "Invalid format for answer, please try again."
        else
          puts invalid_message || "Invalid answer, please try again."
        end
      end
    end  
  end
end