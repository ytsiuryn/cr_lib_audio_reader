require "benchmark"
require "../../src/flac"

Benchmark.ips do |x|
  x.report("FLAC mono full track parsing") do
    r = Release.new
    flac = Flac.new("spec/data/flac/440_hz_mono.flac")
    flac.apply_to(r)
  end
end
