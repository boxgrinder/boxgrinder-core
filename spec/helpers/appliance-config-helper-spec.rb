require 'boxgrinder-core/helpers/appliance-config-helper'
require 'rspec/rspec-config-helper'

module BoxGrinder
  describe ApplianceConfigHelper do
    include RSpecConfigHelper

    def prepare_helper( configs )
      @helper = ApplianceConfigHelper.new( configs )
    end

    it "should merge post sections in right order" do
      config_b = ApplianceConfig.new
      config_b.name = 'b'
      config_b.post['base'] = [ "1_1", "1_2" ]
      config_b.appliances << 'a'

      config_a = ApplianceConfig.new
      config_a.name = 'a'
      config_a.post['base'] = [ "2_1", "2_2" ]

      prepare_helper( { config_b.name => config_b, config_a.name => config_a } )
      @helper.instance_variable_set(:@appliance_config, config_b.clone)

      @helper.merge_post_operations

      config = @helper.instance_variable_get(:@appliance_config)
      config.post['base'].size.should == 4
      config.post['base'].should == ['2_1', '2_2', '1_1', '1_2']
    end

    it "should merge post sections when dependent appliance has post section for platform for which we haven't specified post operations" do
      config_b = ApplianceConfig.new
      config_b.name = 'b'
      config_b.post['base'] = [ "1_1", "1_2" ]
      config_b.appliances << 'a'

      config_a = ApplianceConfig.new
      config_a.name = 'a'
      config_a.post['ec2'] = [ "2_1", "2_2" ]

      prepare_helper( { config_b.name => config_b, config_a.name => config_a } )
      @helper.instance_variable_set(:@appliance_config, config_b.clone)

      @helper.merge_post_operations

      config = @helper.instance_variable_get(:@appliance_config)
      config.post['base'].size.should == 2
      config.post['base'].should == ['1_1', '1_2']
      config.post['ec2'].size.should == 2
      config.post['ec2'].should == ['2_1', '2_2']
    end
  end
end
