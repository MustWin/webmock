require 'spec_helper'

describe WebMock::RequestExecutionVerifier do
  before(:each) do
    @verifier = WebMock::RequestExecutionVerifier.new
    @request_pattern = double(WebMock::RequestPattern, :to_s => "www.example.com")
    @verifier.request_pattern = @request_pattern
    allow(WebMock::RequestRegistry.instance).to receive(:to_s).and_return("executed requests")
    @executed_requests_info = "\n\nThe following requests were made:\n\nexecuted requests\n" + "="*60
  end


  describe "failure message" do

    it "should report failure message" do
      @verifier.times_executed = 0
      @verifier.expected_times_executed = 2
      expected_text = "The request www.example.com was expected to execute 2 times but it executed 0 times"
      expected_text << @executed_requests_info
      expect(@verifier.failure_message).to eq(expected_text)
    end

    it "should report failure message correctly when executed times is one" do
      @verifier.times_executed = 1
      @verifier.expected_times_executed = 1
      expected_text = "The request www.example.com was expected to execute 1 time but it executed 1 time"
      expected_text << @executed_requests_info
      expect(@verifier.failure_message).to eq(expected_text)
    end

    context "at_least_times_executed is set" do
      it "reports failure message correctly when executed times is one" do
        @verifier.times_executed = 1
        @verifier.at_least_times_executed = 2
        expected_text = "The request www.example.com was expected to execute at least 2 times but it executed 1 time"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message).to eq(expected_text)
      end

      it "reports failure message correctly when executed times is two" do
        @verifier.times_executed = 2
        @verifier.at_least_times_executed = 3
        expected_text = "The request www.example.com was expected to execute at least 3 times but it executed 2 times"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message).to eq(expected_text)
      end
    end

    context "at_most_times_executed is set" do
      it "reports failure message correctly when executed times is three" do
        @verifier.times_executed = 3
        @verifier.at_most_times_executed = 2
        expected_text = "The request www.example.com was expected to execute at most 2 times but it executed 3 times"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message).to eq(expected_text)
      end

      it "reports failure message correctly when executed times is two" do
        @verifier.times_executed = 2
        @verifier.at_most_times_executed = 1
        expected_text = "The request www.example.com was expected to execute at most 1 time but it executed 2 times"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message).to eq(expected_text)
      end
    end
  end

  describe "negative failure message" do

    it "should report failure message if it executed number of times specified" do
      @verifier.times_executed = 2
      @verifier.expected_times_executed = 2
      expected_text = "The request www.example.com was not expected to execute 2 times but it executed 2 times"
      expected_text << @executed_requests_info
      expect(@verifier.failure_message_when_negated).to eq(expected_text)
    end

    it "should report failure message when not expected request but it executed" do
      @verifier.times_executed = 1
      expected_text = "The request www.example.com was expected to execute 0 times but it executed 1 time"
      expected_text << @executed_requests_info
      expect(@verifier.failure_message_when_negated).to eq(expected_text)
    end

    context "at_least_times_executed is set" do
      it "reports failure message correctly when executed times is one" do
        @verifier.times_executed = 3
        @verifier.at_least_times_executed = 2
        expected_text = "The request www.example.com was not expected to execute at least 2 times but it executed 3 times"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message_when_negated).to eq(expected_text)
      end

      it "reports failure message correctly when executed times is two" do
        @verifier.times_executed = 2
        @verifier.at_least_times_executed = 2
        expected_text = "The request www.example.com was not expected to execute at least 2 times but it executed 2 times"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message_when_negated).to eq(expected_text)
      end
    end

    context "at_most_times_executed is set" do
      it "reports failure message correctly when executed times is three" do
        @verifier.times_executed = 2
        @verifier.at_most_times_executed = 3
        expected_text = "The request www.example.com was not expected to execute at most 3 times but it executed 2 times"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message_when_negated).to eq(expected_text)
      end

      it "reports failure message correctly when executed times is one" do
        @verifier.times_executed = 1
        @verifier.at_most_times_executed = 2
        expected_text = "The request www.example.com was not expected to execute at most 2 times but it executed 1 time"
        expected_text << @executed_requests_info
        expect(@verifier.failure_message_when_negated).to eq(expected_text)
      end
    end

  end

  describe "matches?" do

    it "should succeed if request was executed expected number of times" do
      expect(WebMock::RequestRegistry.instance).
        to receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 10
      expect(@verifier.matches?).to be_truthy
    end

    it "should fail if request was not executed expected number of times" do
      expect(WebMock::RequestRegistry.instance).
        to receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 5
      expect(@verifier.matches?).to be_falsey
    end

  end

  describe "does_not_match?" do

    it "should fail if request executed expected number of times" do
      expect(WebMock::RequestRegistry.instance).
        to receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 10
      expect(@verifier.does_not_match?).to be_falsey
    end

    it "should succeed if request was not executed at all and expected number of times was not set" do
      expect(WebMock::RequestRegistry.instance).
        to receive(:times_executed).with(@request_pattern).and_return(0)
      expect(@verifier.does_not_match?).to be_truthy
    end

    it "should fail if request was executed and expected number of times was not set" do
      expect(WebMock::RequestRegistry.instance).
        to receive(:times_executed).with(@request_pattern).and_return(1)
      expect(@verifier.does_not_match?).to be_falsey
    end

    it "should succeed if request was not executed expected number of times" do
      expect(WebMock::RequestRegistry.instance).
        to receive(:times_executed).with(@request_pattern).and_return(10)
      @verifier.expected_times_executed = 5
      expect(@verifier.does_not_match?).to be_truthy
    end

  end

end
