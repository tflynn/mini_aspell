require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "MiniAspell" do

  it "should  find an aspell instance" do
    spellchecker_available = MiniSpell.check_for_aspell_binary
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
    a_little_text = %{
      The eximple is
    }
    spell_results = MiniSpell.check_spelling(a_little_text,'en')
    puts spell_results.inspect
  end
  
end
