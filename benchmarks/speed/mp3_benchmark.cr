require "benchmark"
require "core"
require "../../src/mp3"

Benchmark.ips do |x|
  x.report("MP3 mono full track parsing") do
    r = Release.new
    mp3 = MP3.new("spec/data/mp3/440_hz_mono.mp3")
    mp3.apply_to(r)
  end
  x.report("MP3 mono track parsing without pictures") do
    r = Release.new
    r.pictures.hashes << "770d292cb7e348f40b675516c34a89a7263a07d0f5b2b6d1acd2d0f5040e1b28"
    r.pictures.hashes << "e3dce5a4c20e7f495cfb6d39a90513c048c3e0d6d63b78cb20495ae4fdda7b4a"
    mp3 = MP3.new("spec/data/mp3/440_hz_mono.mp3")
    mp3.apply_to(r)
  end
end
