require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "MiniAspell" do

  it "should  find an aspell instance" do
    spellchecker_available =  MiniAspell.check_for_aspell_binary
    #puts "spellchecker_available #{spellchecker_available.inspect}"
    spellchecker_available.should_not be_nil
  end

  it "should  indicate that words are correctly spelt" do
    a_lot_of_text = %{
      The example is passing again, but are we done yet? Scroll up a few lines and take a look 
      at the current implementation of User. I think it’s fair to say that this is NOT the implementation 
      that we know we want to end up with. And this is the point in the process that makes TDD “Test-Driven”. 
      Rather than implementing the code we think  that we know that we want, we’re going to proceed under the 
      guidance of the principle that “code does not exist until it is tested.”
    }
    spell_results =  MiniAspell.check_spelling(a_lot_of_text,'en')
    #puts "spell_results #{spell_results.inspect}"
    spell_results.each do |spell_result|
      spell_result.at(1).should be_nil
    end
  end
  
  it "should tell us when we have spelling errors" do
    a_little_text = %{
      The eximple is  passing again, but are we 
    }
    spell_results =  MiniAspell.check_spelling(a_little_text,'en')
    word, setting = spell_results.at(0)
    setting.should be_nil
    word, setting = spell_results.at(1)
    setting.should_not be_nil
    word, setting = spell_results.at(2)
    setting.should be_nil
  end
  
  it "should handle an array of words" do
    text = %{The example is passing again, but are we done yet? Scroll up a few lines and take a look}
    text_array = text.split(' ')
    spell_results =  MiniAspell.check_spelling(text_array,'en')
    #puts "spell_results #{spell_results.inspect}"
    spell_results.each do |spell_result|
      spell_result.at(1).should be_nil
    end
  end


end
