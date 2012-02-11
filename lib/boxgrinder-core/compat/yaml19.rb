module BoxGrinder
  # Avoid Psych::SyntaxError (<unknown>): couldn't parse YAML ... in 1.9
  if RUBY_VERSION.split('.')[1] == '9'
    require 'yaml'
    YAML::ENGINE.yamler = 'syck'
  end
end
