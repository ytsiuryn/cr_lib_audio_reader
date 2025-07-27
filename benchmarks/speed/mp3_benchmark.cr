require "benchmark"
require "core"
require "../../src/mp3"

Benchmark.ips do |x|
  x.report("MP3 mono full track parsing") do
    r = Release.new
    mp3 = MP3.new("spec/data/mp3/440_hz_mono.mp3")
    mp3.apply_to(r)
  end
end
