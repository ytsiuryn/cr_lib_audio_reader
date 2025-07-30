# Разбор тегов разметки Ape версии 2.X.
#
# [Ape ver.2 specification](https://wiki.hydrogenaud.io/index.php?title=APEv2_specification)

require "bindata"
require "core"

APE_MD_SIGN = "APETAGEX"

COVER_FRONT_TAG = "COVER ART (FRONT)"
COVER_BACK_TAG  = "COVER ART (BACK)"

private class ApeTag < BinData
  endian :little

  field item_len : UInt32
  bit_field do
    bits 1, read_write
    # 0: Item contains text information coded in UTF-8
    # 1: Item contains binary information*
    # 2: Item is a locator of external stored information**
    # 3: reserved
    bits 2, text_encoding
    bits 29, _ignored
  end
  field name : String
  field value : Bytes, length: -> { item_len }

  def text?
    text_encoding == 0
  end

  def picture?
    name.starts_with?("COVER ART")
  end
end

class ApeParser < BinData
  endian :little

  field magic : String, length: -> { 8 }, verify: -> { magic == APE_MD_SIGN }
  # Version: 1000 = Version 1.000 (old); 2000 = Version 2.000 (new)
  field version : UInt32
  # Tag size in bytes including footer and all tag items excluding
  field tag_size : UInt32
  field item_count : UInt32
  field reserved : Bytes, length: -> { 12 }
  field _tags : Array(ApeTag), length: -> { item_count }, onlyif: -> { false }

  def read(io : IO, r : Release, t : Track)
    super(io)

    t.unprocessed = Unprocessed.new(initial_capacity: item_count)
    item_count.times do
      tag = ApeTag.new
      tag.read(io)

      if tag.picture?
        null_pos = tag.value.index(0x00) || tag.value.size - 1
        pict_type = case tag.name
                    when COVER_FRONT_TAG then PictType::COVER_FRONT
                    when COVER_BACK_TAG  then PictType::COVER_BACK
                    else                      PictType::OTHER_ICON
                    end
        p = PictureInAudio.new(pict_type)
        p.url = String.new(tag.value[0, null_pos])
        p.data = tag.value[null_pos + 1..-1]
        r.pictures << p
      elsif tag.text?
        t.unprocessed[tag.name] = String.new(tag.value)
      else
        # @binary_tags[tag.name] = tag.value
      end
    end
  end
end
