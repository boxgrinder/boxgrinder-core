require 'boxgrinder-core/helpers/appliance-config-helper'
require 'rspec/rspec-config-helper'

module BoxGrinder
  describe ApplianceConfigHelper do
    include RSpecConfigHelper

    def prepare_helper( configs )
      @helper = ApplianceConfigHelper.new( configs )
    end

    it "should merge post sections in right order" do
      config_a = ApplianceConfig.new
      config_a.name = 'a'
      config_a.post['base'] = [ "1_1", "1_2" ]
      config_a.appliances << 'b'

      config_b = ApplianceConfig.new
      config_b.name = 'b'
      config_b.post['base'] = [ "2_1", "2_2" ]

      prepare_helper( [ config_a, config_b ] )
      @helper.instance_variable_set(:@appliance_config, config_a.clone)

      @helper.merge_post_operations

      config = @helper.instance_variable_get(:@appliance_config)
      config.post['base'].size.should == 4
      config.post['base'].should == ['2_1', '2_2', '1_1', '1_2']
    end

    it "should merge post sections in right order with more complicated inheritance" do
      config_a = ApplianceConfig.new
      config_a.name = 'a'
      config_a.post['base'] = [ "1_1", "1_2" ]
      config_a.appliances << 'b1'
      config_a.appliances << 'b2'

      config_b1 = ApplianceConfig.new
      config_b1.name = 'b1'
      config_b1.post['base'] = [ "2_1", "2_2" ]

      config_b2 = ApplianceConfig.new
      config_b2.name = 'b2'
      config_b2.post['base'] = [ "3_1", "3_2" ]

      prepare_helper( [ config_a, config_b1, config_b2 ] )
      @helper.instance_variable_set(:@appliance_config, config_a.clone)

      @helper.merge_post_operations

      config = @helper.instance_variable_get(:@appliance_config)
      config.post['base'].size.should == 6
      config.post['base'].should == ['3_1', '3_2', '2_1', '2_2', '1_1', '1_2']
    end

    it "should merge post sections in right order with even more and more complicated inheritance" do
      config_a = ApplianceConfig.new
      config_a.name = 'a'
      config_a.post['base'] = [ "1_1", "1_2" ]
      config_a.appliances << 'b1'
      config_a.appliances << 'b2'

      config_b1 = ApplianceConfig.new
      config_b1.name = 'b1'
      config_b1.appliances << 'c1'
      config_b1.post['base'] = [ "2_1", "2_2" ]

      config_b2 = ApplianceConfig.new
      config_b2.name = 'b2'
      config_b2.appliances << 'c2'
      config_b2.post['base'] = [ "3_1", "3_2" ]

      config_c1 = ApplianceConfig.new
      config_c1.name = 'c1'
      config_c1.post['base'] = [ "4_1", "4_2" ]

      config_c2 = ApplianceConfig.new
      config_c2.name = 'c2'
      config_c2.post['base'] = [ "5_1", "5_2" ]

      prepare_helper( [
              config_a,
              config_b1,
              config_c1,
              config_b2,
              config_c2
      ] )
      @helper.instance_variable_set(:@appliance_config, config_a.clone)

      @helper.merge_post_operations

      config = @helper.instance_variable_get(:@appliance_config)
      config.post['base'].size.should == 10
      config.post['base'].should == ['5_1', '5_2', '3_1', '3_2', '4_1', '4_2', '2_1', '2_2', '1_1', '1_2']
    end

    it "should merge post sections when dependent appliance has post section for platform for which we haven't specified post operations" do
      config_a = ApplianceConfig.new
      config_a.name = 'a'
      config_a.post['base'] = [ "1_1", "1_2" ]
      config_a.appliances << 'b'

      config_b = ApplianceConfig.new
      config_b.name = 'b'
      config_b.post['ec2'] = [ "2_1", "2_2" ]

      prepare_helper( [ config_a, config_b ] )
      @helper.instance_variable_set(:@appliance_config, config_a.clone)

      @helper.merge_post_operations

      config = @helper.instance_variable_get(:@appliance_config)
      config.post['base'].size.should == 2
      config.post['base'].should == ['1_1', '1_2']
      config.post['ec2'].size.should == 2
      config.post['ec2'].should == ['2_1', '2_2']
    end
  end
end
