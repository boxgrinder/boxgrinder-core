require 'boxgrinder-core/helpers/appliance-helper'
require 'rspec/rspec-config-helper'

module BoxGrinder
  describe ApplianceHelper do
    include RSpecConfigHelper

    before(:each) do
      @helper = ApplianceHelper.new( :log => Logger.new('/dev/null') )
    end

    it "should read definition from one file" do
      appliance_config = ApplianceConfig.new
      @helper.should_receive(:read_yaml).with('file.appl').and_return( appliance_config )
      @helper.read_definitions( "file.appl" ).should == [ [ appliance_config ], appliance_config ]
    end

    it "should read definition from two files" do
      appliance_a = ApplianceConfig.new
      appliance_a.name = 'a'
      appliance_a.appliances << "b"

      appliance_b = ApplianceConfig.new
      appliance_b.name = 'b'

      @helper.should_receive(:read_yaml).ordered.with('a.appl').and_return( appliance_a )
      @helper.should_receive(:read_yaml).ordered.with('./b.appl').and_return( appliance_b )

      @helper.read_definitions( "a.appl" ).should == [ [ appliance_a, appliance_b ], appliance_a ]
    end

    it "should read definitions from a tree file structure" do
      appliance_a = ApplianceConfig.new
      appliance_a.name = 'a'
      appliance_a.appliances << "b1"
      appliance_a.appliances << "b2"

      appliance_b1 = ApplianceConfig.new
      appliance_b1.name = 'b1'
      appliance_b1.appliances << "c1"

      appliance_b2 = ApplianceConfig.new
      appliance_b2.name = 'b2'
      appliance_b2.appliances << "c2"

      appliance_c1 = ApplianceConfig.new
      appliance_c1.name = 'c1'

      appliance_c2 = ApplianceConfig.new
      appliance_c2.name = 'c2'

      @helper.should_receive(:read_yaml).ordered.with('a.appl').and_return( appliance_a )
      @helper.should_receive(:read_yaml).ordered.with('./b2.appl').and_return( appliance_b2 )
      @helper.should_receive(:read_yaml).ordered.with('./c2.appl').and_return( appliance_c2 )
      @helper.should_receive(:read_yaml).ordered.with('./b1.appl').and_return( appliance_b1 )
      @helper.should_receive(:read_yaml).ordered.with('./c1.appl').and_return( appliance_c1 )

      @helper.read_definitions( "a.appl" ).should == [ [ appliance_a, appliance_b2, appliance_c2, appliance_b1, appliance_c1 ], appliance_a ]
    end

  end
end
