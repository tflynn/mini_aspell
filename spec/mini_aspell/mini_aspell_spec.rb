require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "MiniAspell" do

  # it "should  find an aspell instance" do
  #   spellchecker_available =  MiniAspell.check_for_aspell_binary
  #   #puts "spellchecker_available #{spellchecker_available.inspect}"
  #   spellchecker_available.should_not be_nil
  # end
  # 
  it "should  indicate that words are correctly spelt" do
    a_lot_of_text = %{
      The example is passing again, but are we done yet? Scroll up a few lines and take a look 
      at the current implementation of User. I think it’s fair to say that this is NOT the implementation 
      that we know we want to end up with. And this is the point in the process that makes TDD “Test-Driven”. 
      Rather than implementing the code we think  that we know that we want, we’re going to proceed under the 
      guidance of the principle that “code does not exist until it is tested.”
    }
    spell_results =  MiniAspell.check_spelling(a_lot_of_text,'en')
    spell_results.empty?.should be_true
  end
  

  it "should tell us when we have spelling errors" do
    a_little_text = %{
      The eximple is  passing again, but are we 
    }
    spell_results =  MiniAspell.check_spelling(a_little_text,'en')
    error_entry = spell_results.at(0)
    word  = error_entry.at(0)
    suggestions = error_entry.at(1)
    suggestions.should_not be_nil
  end

  
  it "should handle an array of words" do
    text = %{The example is passing again, but are we done yet? Scroll up a few lines and take a look}
    text_array = text.split(' ')
    spell_results =  MiniAspell.check_spelling(text_array,'en')
    spell_results.empty?.should be_true
  end


  it "should  indicate that words are correctly spelt in a long document" do
    a_whole_lot_of_text = %{
      RubyGems is the library manager for Ruby.  A library component, or a ‘gem’, is a component at a particular version that may depend on other components at varying versions.
  
      The core features relevant from the perspective of production deployments are:
  
      The default library ‘stack’ is installed and managed globally on any given machine. Though it’s possible to change this, it’s not straightforward
      Dependencies can be specified to be based on exact version matching, or matching based on ‘at least this version’.
      Notification of dependency conflicts is crude - ‘this version of the gem was requested, another one is already loaded’ - no indication of which dependency (tree) caused the conflict
      Forward loading and syntax incompatibilities
      Gems can (and do) depend on specific versions of the library software itself
  
      As a consequence, by default, all application stacks running on the same machine share the same resolved dependency tree. That means that any conflicts in the dependency tree for a specific application have to be resolved across all the dependency trees for all the applications sharing that machine.
  
      Because the notification of dependency conflicts merely reports the end-point in the dependency chain, determining and resolving the root of the conflict can take days. Frequently, a specific load order must be specified to resolve a problem.
  
      As a data point, in an application with 60 explicit dependencies (many more implied dependencies), more than one person-month per year has been spent simply resolving dependency issues.
  
      In moving from RubyGems 1.0.x series to 1.2.x series, the default dependency loading behavior and syntax changed.  This is severe enough in some complex environment that these environments cannot easily and have not upgraded to the newer versions of RubyGems.
  
      Since gems themselves frequently depend on versions of RubyGems itself, upgraded components cannot be used in many cases because of the forward syntax and loading incompatibilities pointed out previously.    
    }
    spell_results =  MiniAspell.check_spelling(a_whole_lot_of_text,'en')
    spell_results.empty?.should be_false
  end

end
