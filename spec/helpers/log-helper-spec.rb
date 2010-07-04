require 'boxgrinder-core/helpers/log-helper'

module BoxGrinder
  describe LogHelper do

    before(:each) do
      @helper = LogHelper.new
      @helper.instance_variable_set(:@stdout_log, Logger.new('/dev/null') )
      @helper.instance_variable_set(:@file_log, Logger.new('/dev/null') )
    end

    it "should initialize properly without arguments with good log levels" do
      FileUtils.should_receive(:mkdir_p).once.with("log")

      @helper = LogHelper.new

      stdout_log  = @helper.instance_variable_get(:@stdout_log)
      file_log    = @helper.instance_variable_get(:@file_log)

      stdout_log.level.should == Logger::INFO
      file_log.level.should == Logger::TRACE
    end

    it "should allow to log in every known log level" do
      @helper.fatal( "fatal" )
      @helper.debug( "debug" )
      @helper.error( "error" )
      @helper.warn( "warn" )
      @helper.info( "info" )
    end

    it "should change log level" do
      FileUtils.should_receive(:mkdir_p).once.with("log")

      @helper = LogHelper.new( :threshold => "debug" )

      stdout_log  = @helper.instance_variable_get(:@stdout_log)
      file_log    = @helper.instance_variable_get(:@file_log)

      stdout_log.level.should == Logger::DEBUG
      file_log.level.should == Logger::TRACE
    end

    it "should change log level" do
      FileUtils.should_receive(:mkdir_p).once.with("log")

      @helper = LogHelper.new( :thrshold => "doesntexists" )

      stdout_log  = @helper.instance_variable_get(:@stdout_log)
      file_log    = @helper.instance_variable_get(:@file_log)

      stdout_log.level.should == Logger::INFO
      file_log.level.should == Logger::TRACE
    end
  end
end
