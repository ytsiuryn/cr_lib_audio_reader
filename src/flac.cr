# Разбор файлов FLAC.
#
# [Спецификация]: (https://xiph.org/flac/format.html)
#

require "bindata"
require "core"
require "./tag"
require "./tag/vorbis"

FLAC_MAGIC    = "fLaC"
IS_LAST_BLOCK = 1_u8

private enum BlockType
  StreamInfo    =   0
  Padding       =   1
  Application   =   2
  Seektable     =   3
  VorbisComment =   4
  CueSheet      =   5
  Picture       =   6
  Unknown       = 127
end

private class BlockHeader < BinData
  endian :big

  bit_field do
    bits 1, is_last_block
    bits 7, _block_type
    bits 24, block_len
  end

  def block_type
    BlockType.from_value?(_block_type) || BlockType::Unknown
  end
end

private class FLACKBlock < BinData
  property header : BlockHeader = BlockHeader.new

  def read_block(io : IO) : Nil
    read(io)
  end

  def process; end
end

private class StreamInfoBlock < FLACKBlock
  endian :big

  field _ignored : Bytes, length: -> { 10 }
  bit_field do
    bits 20, :samplerate
    bits 3, _channels
    bits 5, _samplesize
    bits 36, :total_samples
  end
  field md5_sum : Bytes, length: -> { 16 }

  def initialize(@t : Track); end

  def process
    @t.ainfo = AudioInfo.new(
      channels: _channels.to_i + 1,
      samplesize: _samplesize.to_i + 1,
      samplerate: samplerate.to_i,
      duration: (1000_i64 * total_samples / samplerate).to_i64)
  end
end

private class CueSheetBlock < FLACKBlock
  field _ignored : Bytes, length: -> { 9 }
  field isrc : String, length: -> { 12 }
end

private class PictureBlock < FLACKBlock
  endian :big

  field pict_type : PictType = PictType::UNKNOWN
  field mime_length : UInt32
  field mime : String, length: -> { mime_length }
  field descr_length : UInt32
  field descr : String, length: -> { descr_length }
  field width : UInt32
  field height : UInt32
  field color_depth : UInt32
  field colors : UInt32
  field data_length : UInt32
  field data : Bytes, length: -> { data_length }, onlyif: -> { false }

  def initialize(@r : Release); end

  def read_block(io : IO) : Nil
    super(io)
    if !@r.pictures.hashes.includes?(
         PictureInAudio.identity_hash(pict_type, width.to_i, height.to_i, data_length.to_i)
       )
      @data = Bytes.new(data_length)
      io.read_fully(@data)
    else
      io.skip(data_length)
    end
  end

  def process
    # raise "Incorrect track file info" if t.finfo.fsize == 0
    return if data.empty?
    pict = PictureInAudio.new(pict_type)
    pict.md.mime = mime
    pict.md.width = width.to_i
    pict.md.height = height.to_i
    if PictureInAudio.file_reference?(descr)
      pict.url = descr
    else
      pict.notes << descr
    end
    pict.data = data
    @r.pictures << pict
  end
end

private class VorbisCommentBlock < FLACKBlock
  field comments : VorbisComments = VorbisComments.new

  def initialize(@t : Track); end

  def process
    @t.unprocessed = comments.comments
  end
end

class FLAC < BinData
  field stream_marker : String, length: -> { 4 }, verify: -> { stream_marker == FLAC_MAGIC }
  @md_len = 0_u64

  def initialize(fn : String)
    @t = Track.new(path: fn)
    @io = File.open(fn, mode: "rb")
  end

  def apply_to(r : Release)
    read(@io)

    loop do
      header = BlockHeader.new
      header.read(@io)

      block = case header.block_type
              when BlockType::StreamInfo    then StreamInfoBlock.new(@t)
              when BlockType::VorbisComment then VorbisCommentBlock.new(@t)
              when BlockType::Picture       then PictureBlock.new(r)
              when BlockType::CueSheet      then CueSheetBlock.new
              else                               @io.skip(header.block_len)
              end

      if block
        block.header = header
        block.read_block(@io)
        block.process
      end
      @md_len += header.block_len if header.block_type < BlockType::Unknown

      break if header.is_last_block == IS_LAST_BLOCK
    end
    @t.ainfo.avg_bitrate = (8 * (@t.finfo.fsize - @md_len) / @t.ainfo.duration).to_i

    r.tracks << @t

    TagProcessor.new(r, @t, Schema::VORBIS_COMMENT).process
  end
end
