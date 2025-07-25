require "bindata"

private class Comment < BinData
  # endian :little

  field len : UInt32
  field val : String, length: -> { len }
end

class VorbisComments < BinData
  endian :little

  field libdata_len : UInt32
  field libdata : String, length: -> { libdata_len }
  field comment_count : UInt32

  field _comments : Array(Comment), length: -> { comment_count }

  def comments
    _comments.each_with_object({} of String => String) do |comment, hash|
      key, value = comment.val.split('=', limit: 2)
      hash[key] = value
    end
  end
end
