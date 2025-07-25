# Разбор файлов MP3.
#
# [Структура заголовка](https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Mp3filestructure.svg/1257px-Mp3filestructure.svg.png)
# [Спецификация](http://www.mp3-tech.org/programmer/docs/mp3_theory.pdf)
#
# Версия MPEG 2.5 не поддерживается.

require "bindata"
require "core"
require "./tag"
require "./tag/id3/v1"
require "./tag/id3/v2"

enum MPEGVersion
  MPEG2
  MPEG1
end

# Layer Type
enum Layer
  RESERVED
  LAYER_3
  LAYER_2
  LAYER_1
end

BITRATE_MAP = {
  MPEGVersion::MPEG1 => {
    Layer::LAYER_1 => {
       1 => 32,
       2 => 64,
       3 => 96,
       4 => 128,
       5 => 160,
       6 => 192,
       7 => 224,
       8 => 256,
       9 => 288,
      10 => 320,
      11 => 352,
      12 => 384,
      13 => 416,
      14 => 448,
    },
    Layer::LAYER_2 => {
       1 => 32,
       2 => 48,
       3 => 56,
       4 => 64,
       5 => 80,
       6 => 96,
       7 => 112,
       8 => 128,
       9 => 160,
      10 => 192,
      11 => 224,
      12 => 256,
      13 => 320,
      14 => 384,
    },
    Layer::LAYER_3 => {
       1 => 32,
       2 => 40,
       3 => 48,
       4 => 56,
       5 => 64,
       6 => 80,
       7 => 96,
       8 => 112,
       9 => 128,
      10 => 160,
      11 => 192,
      12 => 224,
      13 => 256,
      14 => 320,
    },
  },
  MPEGVersion::MPEG2 => {
    Layer::LAYER_1 => {
       1 => 32,
       2 => 64,
       3 => 96,
       4 => 128,
       5 => 160,
       6 => 192,
       7 => 224,
       8 => 256,
       9 => 288,
      10 => 320,
      11 => 352,
      12 => 384,
      13 => 416,
      14 => 448,
    },
    Layer::LAYER_2 => {
       1 => 32,
       2 => 48,
       3 => 56,
       4 => 64,
       5 => 80,
       6 => 96,
       7 => 112,
       8 => 128,
       9 => 160,
      10 => 192,
      11 => 224,
      12 => 256,
      13 => 320,
      14 => 384,
    },
    Layer::LAYER_3 => {
       1 => 8,
       2 => 16,
       3 => 24,
       4 => 32,
       5 => 64,
       6 => 80,
       7 => 56,
       8 => 64,
       9 => 128,
      10 => 160,
      11 => 112,
      12 => 128,
      13 => 256,
      14 => 320,
    },
  },
}

# FrequencyMap describes audio samlerate
FREQUENCY_MAP = {
  MPEGVersion::MPEG1 => {
    0 => 44100,
    1 => 48000,
    2 => 32000,
  },
  MPEGVersion::MPEG2 => {
    0 => 22050,
    1 => 24000,
    2 => 16000,
  },
}

class MP3Header < BinData
  endian :big

  bit_field do
    bits 12, sync : UInt8 #, verify: -> { sync == 0xFFF }
    bits 1, mpeg_version : MPEGVersion = MPEGVersion::MPEG1
    bits 2, layer : Layer = Layer::RESERVED
    bits 1, _protection
    bits 4, _bitrate
    bits 2, _frequency
    bits 1, _padding
    bits 1, _private
    bits 2, mode
    bits 2, mode_extension
    bits 1, _copyright
    bits 1, _original
    bits 2, _emphasis
  end

  def avg_bitrate
    BITRATE_MAP[mpeg_version][layer][_bitrate]
  end

  def samplerate
    FREQUENCY_MAP[mpeg_version][_frequency]
  end
end

class MP3 < BinData
  def initialize(fn : String)
    @t = Track.new(path: fn)
    @io = File.open(fn, mode: "rb")
  end

  private def starts_with_id3v2_block
    pos = @io.pos
    result = @io.read_string(ID3_MAGIC.size)
    @io.pos = pos
    result == ID3_MAGIC
  end

  def apply_to(r : Release)
    if starts_with_id3v2_block
      id3 = ID3v2Parser.new
      id3.read(@io, r, @t)
    end

    # mp3 = MP3Header.new
    # mp3.read(@io)
    
    # TODO: читать теги ID3V1
    # pp! mp3.mpeg_version, mp3.layer
    
    # @t.ainfo = AudioInfo.new(avg_bitrate: mp3.avg_bitrate, samplerate: mp3.samplerate)

    r.tracks << @t

    TagProcessor.new(r, @t, Schema::ID3_V2).process
  end
end
