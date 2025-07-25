# Разбор файлов DSF.
#
# [Спецификация](http://dsd-guide.com/sites/default/files/white-papers/DSFFileFormatSpec_E.pdf)
#

require "bindata"
require "./tag"
require "./tag/id3/v2"

DSF_MAGIC = "DSD "
FMT_SIGN  = "fmt "

# Общий заголовок
private class DsfChunk < BinData
  endian :little

  field magic : String, length: -> { 4 }, verify: -> { magic == DSF_MAGIC }
  field chunk_size : UInt64
  field file_size : UInt64
  field id3_offset : UInt64
end

# audio stream info
private class FmtChunk < BinData
  endian :little

  enum ChannelType
    Mono               = 1
    Stereo             = 2
    ThreeChannels      = 3
    Quad               = 4
    FourChannels       = 5
    FiveChannels       = 6
    FiveDorOneChannels = 7
  end

  field fmt_sign : String, length: -> { 4 }, verify: -> { fmt_sign == FMT_SIGN }
  field chunk_size : UInt64
  field fmt_ver : UInt32
  field fmt_id : UInt32 # 0 : DSD raw
  field channel_type : ChannelType = ChannelType::Stereo
  field channels : UInt32
  field samplerate : UInt32
  field samplesize : UInt32
  field sample_count : UInt64

  def duration
    (sample_count * 1000 / samplerate).to_i64
  end
end

class Dsf < BinData
  def initialize(fn : String)
    @track = Track.new(path: fn)
    @io = File.open(fn, mode: "rb")
  end

  def apply_to(r : Release)
    dsf_chunk = DsfChunk.new
    dsf_chunk.read(@io)

    fmt_chunk = FmtChunk.new
    fmt_chunk.read(@io)

    @io.pos = dsf_chunk.id3_offset

    id3 = ID3v2Parser.new
    id3.read(@io, r, @track)

    duration = fmt_chunk.duration
    @track.ainfo = AudioInfo.new(
      channels: fmt_chunk.channels.to_i,
      samplerate: fmt_chunk.samplerate.to_i,
      samplesize: fmt_chunk.samplesize.to_i,
      duration: duration,
      avg_bitrate: (8*(@track.finfo.fsize - 28 - 52 - id3.size) / duration).to_i
    )

    r.tracks << @track

    TagProcessor.new(r, @track, Schema::ID3_V2).process
  end
end
