# Put your gem code here:
$KCODE = 'u'
require 'jcode'
require 'tempfile'

class MiniAspell

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
      aspell_binary_cmd = MiniAspell.check_for_aspell_binary
      return nil if aspell_binary_cmd.nil?
      all_words = []
      if text_to_check.kind_of?(String)
        lines = text_to_check.split("\n")
        lines.each do |line|
          #puts "raw input line >>#{line}<<"
          stripped_chomped_line = line.chomp.strip
          #puts "stripped_chomped_line >>#{stripped_chomped_line}<<"
          next if stripped_chomped_line == ''
          words = line.chomp.split(' ')
          #puts "adding words to list #{words.inspect}"
          all_words.concat(words)
        end
      elsif text_to_check.kind_of?(Array)
        all_words = text_to_check
      else
        return nil
      end
      clean_words = []
      # all_words.each do |word|
      #   #puts "checking >>#{word}<< for unicode chars"
      #   # Ignore words containing unicode characters
      #   if word.length == word.jlength
      #     #puts "No unicode chars so ok for word #{word}"
      #     clean_words << word
      #   else
      #     #puts "found unicode char in word >>#{word}<<. Ignoring"
      #   end
      # end
      clean_words = all_words
      
      return nil if clean_words.empty?
      #puts "clean_words #{clean_words.inspect}"
      full_aspell_cmd = "#{aspell_binary_cmd} --lang=#{language} -a check"
      spell_results = MiniAspell.execute_cmd(full_aspell_cmd, clean_words)
      spell_results = spell_results.split("\n")
      # Skip header line
      spell_results.shift
      #puts "spell_results #{spell_results.inspect}"
      
      return MiniAspell.parse_outputs(spell_results)
    end

    
    def suggest_spelling(text_to_check,language = "en")
      return MiniAspell.check_spelling(text_to_check,language)
    end


    # def execute_cmd(cmd,inputs)
    #   outputs = []
    #   read_pipe, write_pipe = IO.pipe
    #   pid = fork {
    #       # child
    #       $stdout.reopen write_pipe
    #       read_pipe.close
    #       cmd_input = IO.popen(cmd,'w')
    #       inputs.each {|input| cmd_input.puts input}
    #       cmd_input.close
    #       $stdout.close
    #   }
    #   # parent
    #   write_pipe.close
    #   read_pipe.each do |line|
    #       outputs << line
    #   end
    #   read_pipe.close
    #   Process.waitpid(pid)
    #   return outputs
    # end

    def execute_cmd(cmd,inputs)
      outputs = []
      input_file = Tempfile.new("spellcheck_in")
      #puts "input_file #{input_file.path}"
      inputs.each do | input |
        input_file.puts input
      end
      input_file_path = input_file.path
      input_file.close
      #puts `cat #{input_file.path}`
      full_cmd = %{cat #{input_file.path} | #{cmd} }
      #puts "full_cmd #{full_cmd}"
      results = `#{full_cmd}`
      #puts "results #{results.inspect}"
      return results
    end

    def parse_outputs(outputs)

      #puts "outputs (#{outputs.size}) #{outputs.inspect}"
      
      parsed_results  = []
      process_entry = true
      outputs.each do |output|
        if process_entry
          cleaned_entry = output.chomp
          #puts "cleaned_entry >>#{cleaned_entry.inspect}<<"
          next if cleaned_entry == ''
          parsed_result = MiniAspell.parse_output(cleaned_entry)
          #puts "parsed_result #{parsed_result.inspect}"
          # Only included errors
          unless parsed_result.nil?
            parsed_results << parsed_result
          end
        end
        process_entry = ! process_entry
      end

      return parsed_results
      
    end

    def parse_output(output_entry)
      #puts "output_entry #{output_entry.inspect}"
      if output_entry[0,1] == '*'
        return nil
      elsif output_entry[0,1] == '&'
        preamble, raw_suggestions = output_entry.split(':')
        original_word = preamble.split(" ").at(1)
        suggestions = raw_suggestions.split(',')
        return [original_word, suggestions]
      else
        return nil
      end
    end
    
  end
end
