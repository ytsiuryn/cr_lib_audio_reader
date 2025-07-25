require "benchmark"
require "core"
require "../../src/wv"

Benchmark.ips do |x|
  x.report("WavPack mono full track parsing") do
    r = Release.new
    wv = WavPack.new("spec/data/wv/440_hz_mono.wv")
    wv.apply_to(r)
  end
end
