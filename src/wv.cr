# Разбор файлов Wavpack.
#
# [Specification](https =>//www.wavpack.com/WavPack5FileFormat.pdf)

require "bindata"
require "core"
require "./tag"
require "./tag/ape"

WV_BLOCK_SIGN = "wvpk"
WV_HEADER_SIZE   = 32

# Не указанные в мапе =>
# 0b0000 	get from STREAMINFO metadata block
# 0b1100 	get 8 bit sample rate (in kHz) from end of header
# 0b1101 	get 16 bit sample rate (in Hz) from end of header
# 0b1110 	get 16 bit sample rate (in tens of Hz) from end of header
# 0b1111 	invalid, to prevent sync-fooling string of 1s
SAMPLERATES = {
   1 => 88200,
   2 => 176400,
   3 => 192000,
   4 => 8000,
   5 => 16000,
   6 => 22050,
   7 => 24000,
   8 => 32000,
   9 => 44100,
  10 => 48000,
  11 => 96000,
}

private class WvHeader < BinData
  endian :little

  field ck_id : String, length: -> { 4 }, verify: -> { ck_id == "wvpk" }
  field ck_size : UInt32        # size of entire block (minus 8)
  field version : UInt16        # 0x402 to 0x410 are valid for decode
  field h_block_index : UInt8   # upper 8 bits of 40-bit block_index (since v.5)
  field h_total_samples : UInt8 # upper 8 bits of 40-bit total_samples (since v.5)
  # lower 32 bits of total samples for
  # entire file, but this is only valid
  # if block_index == 0 and a value of -1
  # indicates an unknown length
  field l_total_samples : UInt32
  # lower 32 bit index of the first sample
  # in the block relative to file start,
  # normally this is zero in first block
  field l_block_index : UInt32
  # number of samples in this block, 0 =
  # non-audio block
  field block_samples : UInt32
  # Flags: u32
  bit_field do
    # various flags for id and decoding
    # bits 1,0:   00 = 1 byte / sample (1-8 bits / sample)
    #             01 = 2 bytes / sample (9-16 bits / sample)
    #             10 = 3 bytes / sample (15-24 bits / sample)
    #             11 = 4 bytes / sample (25-32 bits / sample)
    bits 2, :bytes_per_sample
    bits 1, :channel_mode           # 0 = stereo output; 1 = mono output
    bits 1, :lossless_mode          # 0 = lossless mode; 1 = hybrid mode
    bits 1, :stereo_mode            # 0 = true stereo; 1 = joint stereo (mid/side)
    bits 1, :independent_channels   # 0 = independent channels; 1 = cross-channel decorrelation
    bits 1, :noise_spectrum         # 0 = flat noise spectrum in hybrid; 1 = hybrid noise shaping
    bits 1, :num_type_data          # 0 = integer data; 1 = floating point data
    bits 1, :extended_size_integers # 1 = extended size integers (> 24-bit) or shifted integers
    # 0 = hybrid mode parameters control noise level (not used yet)
    # 1 = hybrid mode parameters control bitrate
    bits 1, :hybrid_mode_parameters
    bits 1, :hybrid_noise_balance      # 1 = hybrid noise balanced between channels
    bits 1, :initial_block_in_sequence # 1 = initial block in sequence (for multichannel)
    bits 1, :final_block_in_sequence   # 1 = final block in sequence (for multichannel)
    bits 5, :amount_of_data_left_shift # amount of data left-shift after decode (0-31 places)
    bits 5, :max_magnitude             # max magnitude of decoded data (num of bits integers require minus 1)
    bits 4, :sampling_rate             # sampling rate (1111 = unknown/custom)
    bits 1, :reserved                  # reserved (but decoders should ignore if set)
    bits 1, :check_sum_in_last_bytes   # block contains checksum in last 2 or 4 bytes (ver 5.0+)
    bits 1, :use_iir                   # 1 = use IIR for negative hybrid noise shaping
    bits 1, :false_stereo              # 1 = false stereo (data is mono but output is stereo)
    bits 1, :pcm_or_dsd                # 0 = PCM audio; 1 = DSD audio (ver 5.0+)
  end

  field _crc : UInt32

  def samplesize
    8 << bytes_per_sample
  end

  def total_samples
    l_total_samples | (h_total_samples << 32)
  end

  def channels
    2 - channel_mode
  end

  def samplerate
    SAMPLERATES.fetch(sampling_rate, 0)
  end

  def duration
    1000 * total_samples / samplerate ? samplerate > 0 : 0
  end
end

class WavPack < BinData
  def initialize(fn : String)
    @t = Track.new(path: fn)
    @io = File.open(fn, mode: "rb")
  end

  def apply_to(r : Release)
    read(@io)

    header = WvHeader.new
    header.read(@io)
    @io.pos = header.ck_size + 8

    ape = ApeParser.new
    ape.read(@io, r, @t)

    # raise "Incorrect track file info" if t.finfo.fsize == 0
    @t.ainfo = AudioInfo.new(
      channels = header.channels.to_i,
      samplesize = header.samplesize.to_i,
      samplerate = header.samplerate.to_i,
      # duration = ai.duration.to_i64
      # abg_bitrate = (8 * (t.finfo.fsize - @md_len) / ai.duration).to_i,
    )

    r.tracks << @t

    TagProcessor.new(r, @t, Schema::APE_V2).process
  end
end
