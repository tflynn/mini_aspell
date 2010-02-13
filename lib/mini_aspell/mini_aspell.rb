# Put your gem code here:

class MiniSpell

  @@aspell_binary = nil
  
  class << self
    
    
    def check_for_aspell_binary
      results = nil
      begin
        results = `which aspell`.chomp
        if results.nil? or results == ''
          results = nil
        else
          return results
        end
      rescue Exception => ex
        #TODO Some kind of notification
      end
      
      return results
    end
  
    def check_spelling(text_to_check,language = "en")
      aspell_binary_cmd = MiniSpell.check_for_aspell_binary
      return nil if aspell_binary_cmd.nil?
      all_words = []
      if text_to_check.kind_of?(String)
        lines = text_to_check.split("\n")
        lines.each do |line|
          words = line.chomp.split(' ')
          all_words.concat(words)
        end
      elsif text_to_check.find_of?(Array)
        all_words = text_to_check
      end
      return nil if all_words.empty?
      full_aspell_cmd = "#{aspell_binary_cmd} --lang=#{language} -a "
      puts "About to run #{full_aspell_cmd}"
      spell_results = execute_cmd(full_aspell_cmd, all_words)
      return spell_results
    end
    
    def suggest_spelling()
      
    end
    
    private
    
    def execute_cmd(cmd,inputs)
      outputs = []
      read_pipe, write_pipe = IO.pipe
      pid = fork {
          # child
          $stdout.reopen write_pipe
          read_pipe.close
          cmd_input = IO.popen(cmd,'w')
          inputs.each {|input| cmd_input.puts input}
          cmd_input.close
          $stdout.close
      }
      # parent
      write_pipe.close
      read_pipe.each do |line|
          outputs << line
      end
      read_pipe.close
      Process.waitpid(pid)
      return outputs
    end
  end
  
end
