# Put your gem code here:
$KCODE = 'u'
require 'jcode'

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
          clean_words = []
          words.each do |word|
            # Ignore words containing unicode characters
            if word.length == word.jlength
              clean_words << word
            end
          end
          all_words.concat(clean_words)
        end
      elsif text_to_check.find_of?(Array)
        all_words = text_to_check
      end
      return nil if all_words.empty?
      full_aspell_cmd = "#{aspell_binary_cmd} --lang=#{language} -a "
      spell_results = MiniAspell.execute_cmd(full_aspell_cmd, all_words)
      #puts "spell_results #{spell_results.inspect}"
      # Skip header line
      spell_results.shift
      return MiniAspell.match_and_parse_inputs_and_outputs(all_words,spell_results)
    end

    
    def suggest_spelling(text_to_check,language = "en")
      return MiniAspell.check_spelling(text_to_check,language)
    end


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

    def match_and_parse_inputs_and_outputs(inputs,outputs)

      #puts "inputs (#{inputs.size}) #{inputs.inspect}"
      #puts "outputs (#{outputs.size}) #{outputs.inspect}"
      
      cleaned_outputs = []
      add_output = true
      outputs.each do |output|
        cleaned_outputs << output.chomp if add_output
        add_output = ! add_output
      end

      if cleaned_outputs.length != inputs.length
        #puts "Woops, input and output elements don't match"
        return nil
      end
      
      combined_outputs = []
      how_many = inputs.length
      how_many.times do |this_one|
        current_input = inputs.at(this_one)
        current_output = MiniAspell.parse_output(cleaned_outputs.at(this_one))
        combined_outputs << [current_input,current_output]
      end

      return combined_outputs
      
    end

    def parse_output(output_entry)
      if output_entry[0,1] == '*'
        return nil
      elsif output_entry[0,1] == '&'
        preamble, raw_suggestions = output_entry.split(':')
        suggestions = raw_suggestions.split(',')
        return suggestions
      else
        return nil
      end
    end
    
  end
end
