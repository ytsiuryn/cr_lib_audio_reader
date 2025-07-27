# Разбор тегов разметки ID3 версии 1.X.
#
# [Metadata structure](https://id3.org/ID3v1)
#
# [Genre codes](https://en.wikipedia.org/wiki/List_of_ID3v1_Genres)

require "bindata"

ID3V1_MAGIC       = "TAG"
ID3V1_HEADER_SIZE = 128

class ID3v1Parser < BinData
  field tag : String, length: -> { 3 }, verify: -> { tag == ID3V1_MAGIC }
  field song_name : String, length: -> { 30 }
  field artist : String, length: -> { 30 }
  field album_name : String, length: -> { 30 }
  field _year : String, length: -> { 4 }
  field comment : String, length: -> { 30 }
  field genre : UInt8 # TODO: стоит ли описывать?

  def year
    Int32.from(_year)
  end
end
