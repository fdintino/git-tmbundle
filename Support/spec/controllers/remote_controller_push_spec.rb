require File.dirname(__FILE__) + '/../spec_helper'

describe RemoteController do
  include SpecHelpers
  
  before(:each) do
    Git.reset_mock!
  end
  
  describe "pushing" do
    before(:each) do
      Git.command_response["push", "origin"] = (fixture_file("push_1_5_4_3_output.txt"))
      Git.command_response["log", "-p", "60a254470cd97af3668ed4d6405633af850139c6..746fba2424e6b94570fc395c472805625ab2ed25", "."] = fixture_file("log_with_diffs.txt")
      Git.command_response["branch"] = "* master\n  task"
      Git.command_response["log", ".", "865f920..f9ca10d"] = fixture_file("log_with_diffs.txt")
    end
    
    describe "to a server with one origin" do
      before(:each) do
        Git.command_response["remote"] = %Q{origin}
        @output = capture_output do
          dispatch :controller => "remote", :action => "push"
        end
      end
      
      it "should run all git commands" do
        Git.commands_ran.should == [["remote"], ["push", "origin"], ["log", ".", "865f920..f9ca10d"], ["branch"]]
      end
      
      it "should output log with diffs" do
        puts (@output)
        @output.should include("Branch 'asdf': 865f920..f9ca10d")
      end
    end
  end
end