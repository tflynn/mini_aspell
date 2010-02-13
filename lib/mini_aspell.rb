Dir.glob(File.join(File.dirname(__FILE__), 'mini_aspell', '**/*.rb')).each do |f|
  require File.expand_path(f)
end
