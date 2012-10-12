#require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.configure_rspec_metadata!
  c.default_cassette_options = {:record => :once, :allow_playback_repeats => true}
  c.hook_into :webmock
end
