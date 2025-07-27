# Разбор тегов разметки ID3 версии 2.X.
#
# [Общая спецификация](https://id3.org/id3v2.3.0)
#
# [Формат тэгов](http://id3.org/id3v2.4.0-frames)

require "bindata"
require "core"

ID3_MAGIC = "ID3"

def block_size(_size)
  _size.reduce(0) do |acc, byte|
    acc <<= 7
    acc |= byte
  end
end

# Music CD identifier, ID: "MCDI"
# CD TOC <binary data>
# class CdIdValue < FrameValue
# end

private class FrameValue < BinData
  def initialize(@sz : Int32); end
end

private class TextFrameValue < FrameValue
  field encoding : UInt8
end

private class LngTextFrameValue < TextFrameValue
  field language : String, length: -> { 3 }
end

# Text information frames, ID: "T000" - "TZZZ", excluding "TXXX"
private class InfoFrameValue < TextFrameValue
  field text : String, length: -> { @sz - 1 }

  def parse(io : IO)
    read(io)
    text
  end
end

# User defined text information frame, ID: "TXXX"
private class UserInfoFrameValue < TextFrameValue
  field description : String # TODO: это обработает $00 (00) ?
  field text : String, length: -> { @sz - 1 - description.size - 1 }

  def parse(io : IO)
    read(io)
    {description: description, text: text}
  end
end

# Unsychronised lyrics/text transcription, ID: "USLT"
private class UnsyncedLyricsValue < LngTextFrameValue
  field description : String # TODO: это обработает $00 (00) ?
  field text : String, length: -> { @sz - 1 - 3 - description.size }

  def parse(io : IO)
    read(io)
    {lng: language, text: text}
  end
end

# # Synchronised lyrics/text, ID: "SYLT"
private class SyncedLyricsValue < LngTextFrameValue
  field timestamp_fmt : UInt8
  field content_type : UInt8
  field content_descriptor : String, length: -> { @sz - 1 - 3 - 1 - 1 }

  def parse(io : IO)
    read(io)
    {lng: language, text: content_descriptor}
  end
end

# Comments, ID: "COMM"
private class CommentValue < LngTextFrameValue
  field short_descrription : String # TODO: это обработает $00 (00) ?
  field text : String, length: -> { @sz - 1 - 3 - short_descrription.size - 1 }

  def parse(io : IO)
    read(io)
    text
  end
end

# Attached picture, ID: "APIC"
private class PictureValue < TextFrameValue
  field mime : String
  field _pict_type : UInt8
  field description : String # TODO: это обработает $00 (00) ?
  field pict_data : Bytes, length: -> { @sz - 1 - mime.size - 1 - description.size - 2 }

  def pict_type
    PictType.new(_pict_type)
  end

  def parse(io : IO)
    read(io)
    p = PictureInAudio.new(pict_type)
    p.md.mime = mime
    if PictureInAudio.file_reference?(description)
      p.url = description
    else
      p.notes << description
    end
    p.data = pict_data
    p
  end
end

private class TagHeader < BinData
  endian :little

  field frame_id : String, length: -> { 4 }
  field _frame_sz : Bytes, length: -> { 4 }
  field _flags : Bytes, length: -> { 2 }

  getter frame_id

  def frame_sz
    block_size(_frame_sz)
  end
end

class ID3v2Parser < BinData
  endian :little

  field _magic : String, length: -> { 3 }, verify: -> { _magic == ID3_MAGIC }
  field _version : Bytes, length: -> { 2 }
  field _flags : UInt8
  field _size : Bytes, length: -> { 4 }

  def size # TODO: нужен для md_len/avg_bitrate
    block_size(_size)
  end

  def read(io : IO, r : Release, t : Track)
    super(io)

    loop do
      tag = TagHeader.new
      tag.read(io)

      break if tag.frame_id == "\u0000\u0000\u0000\u0000"

      case tag.frame_id
      when "TXXX"
        data = UserInfoFrameValue.new(tag.frame_sz).parse(io)
        key = "TXXX=>#{data[:description]}"
        t.unprocessed[key] = data[:text]
      when "USLT"
        data = UnsyncedLyricsValue.new(tag.frame_sz).parse(io)
        lyrics = Lyrics.new
        lyrics.lng = data[:lng]
        lyrics.text = data[:text]
        t.composition.lyrics = lyrics
      when "SYLT"
        data = SyncedLyricsValue.new(tag.frame_sz).parse(io)
        lyrics = Lyrics.new
        lyrics.lng = data[:lng]
        lyrics.text = data[:text]
        t.composition.lyrics = lyrics
      when /^T/
        txt = InfoFrameValue.new(tag.frame_sz).parse(io)
        t.unprocessed[tag.frame_id] = txt
      when "APIC"
        r.pictures << PictureValue.new(tag.frame_sz).parse(io)
      when "COMM"
        t.unprocessed[tag.frame_id] = CommentValue.new(tag.frame_sz).parse(io)
      else
        io.skip(tag.frame_sz)
      end
    end
    # io.skip(size - io.pos + 10) # 10 - размер заголовка
  end
end
