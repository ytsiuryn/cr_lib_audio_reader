require "benchmark"
require "core"
require "../../src/dsf"

Benchmark.ips do |x|
  x.report("DSF mono full track parsing") do
    r = Release.new
    dsf = DSF.new("spec/data/dsf/440_hz_mono.dsf")
    dsf.apply_to(r)
  end
end
