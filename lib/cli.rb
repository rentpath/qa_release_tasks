module CLI
  def ask(question, default=nil, answers=nil)
    loop do
      print "#{question}"
      print "[#{default}]" if default
      print ": "
      input = STDIN.gets.chomp
      input = default if default && input.empty?
      if answers.nil? || answers.include?(input)
        return input
      else
        puts "Invalid answer, please try again. Valid answers include:"
        puts answers
      end
    end  
  end
end