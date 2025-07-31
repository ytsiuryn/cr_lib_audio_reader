require "benchmark"
require "../../src/flac"

Benchmark.ips do |x|
  x.report("FLAC mono full track parsing") do
    r = Release.new
    flac = FLAC.new("spec/data/flac/440_hz_mono.flac")
    flac.apply_to(r)
  end

  x.report("FLAC mono track parsing without pictures") do
    r = Release.new
    r.pictures.hashes << "ebe866d790104744274e9c96bfb408cca03a3c7908b3b32132b371a5053bb51b"
    r.pictures.hashes << "039e5a055516daec75c3a9857308a7ed1ca53d8a18b323d38674974419efcef8"
    flac = FLAC.new("spec/data/flac/440_hz_mono.flac")
    flac.apply_to(r)
  end
end
