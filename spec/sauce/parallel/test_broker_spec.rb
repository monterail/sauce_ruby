require "json"
require "rspec"
require "sauce/parallel/test_broker"

describe Sauce::TestBroker do

  describe "#next_environment" do

    before :each do
      Sauce::TestBroker.reset
    end

    it "returns the first browser for new entries" do
      first_environment = Sauce::TestBroker.next_environment ["spec/a_spec"]
      first_environment.should eq({
        :SAUCE_PERFILE_BROWSERS => (
          "'" +
          JSON.generate({"./spec/a_spec" => [{"os" => "Windows 7",
                                              "browser" => "Opera",
                                              "version" => "10"}]}) +
          "'")
      })
    end

    it "only returns a browser once for a given file" do
      Sauce::TestBroker.next_environment ["spec/a_spec"]
      second_environment = Sauce::TestBroker.next_environment ["spec/a_spec"]

      second_environment.should eq({
        :SAUCE_PERFILE_BROWSERS => (
          "'" +
          JSON.generate({"./spec/a_spec" => [{"os" => "Linux",
                                              "browser" => "Firefox",
                                              "version" => "19"}]}) +
          "'")
      })
    end

    it "returns multiple browsers for files given multiple times" do
      first_environment = Sauce::TestBroker.next_environment ["spec/a_spec",
                                                              "spec/a_spec"]
      first_environment.should eq({
        :SAUCE_PERFILE_BROWSERS => (
          "'" +
          JSON.generate({"./spec/a_spec" => [{"os" => "Windows 7",
                                              "browser" => "Opera",
                                              "version" => "10"},
                                             {"os" => "Linux",
                                              "browser" => "Firefox",
                                              "version" => "19"}]}) +
          "'")
      })
    end

    it "uses the first browser for each of multiple files" do
      first_environment = Sauce::TestBroker.next_environment ["spec/a_spec",
                                                              "spec/b_spec"]
      first_environment.should eq({
        :SAUCE_PERFILE_BROWSERS => (
          "'" +
          JSON.generate({"./spec/a_spec" => [{"os" => "Windows 7",
                                              "browser" => "Opera",
                                              "version" => "10"}],
                         "./spec/b_spec" => [{"os" => "Windows 7",
                                              "browser" => "Opera",
                                              "version" => "10"}]}) +
          "'")
      })
    end
  end

  describe "#test_platforms" do
    it "should report the same groups as configured in Sauce.config" do
      Sauce::TestBroker.test_platforms.should eq Sauce.get_config.browsers
    end
  end
end
