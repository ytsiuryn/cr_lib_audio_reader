require "core"

# Описание поддерживаемых системой схем кодирования.
enum Schema
  ID3_V2         = 1 # Dsf, Wv
  VORBIS_COMMENT = 2 # Flac
  APE_V2         = 3 # Wv
end

# Обобщенные теги для различных схем тегирования.
#
# https://picard-docs.musicbrainz.org/en/appendices/tag_mapping.html
enum Tag
  # Titles -->
  AlbumTitle
  DiscSetSubtitle
  # ContentGroup,
  TrackTitle
  TrackSubtitle
  # Version
  # People & Organizations -->
  AlbumArtist
  TrackArtist
  Arranger
  AuthorWriter
  Writer
  Composer
  Conductor
  Engineer
  Ensemble
  InvolvedPeople
  Lyricist
  MixDJ
  MixEngineer
  # MusicianCredits
  # Organisation
  # OriginalArtist
  Performer
  Producer
  Publisher
  Label
  LabelNumber
  RemixedBy
  Soloists
  # Counts & Indexes -->
  DiscNumber
  DiscTotal
  TrackNumber
  TrackTotal
  # PartNumber
  Length
  # Dates -->
  ReleaseDate
  Year
  OriginalReleaseDate
  RecordingDates
  # Identifiers -->
  Isrc
  Barcode
  CatalogueNumber
  Upc
  DiscID
  AccurateRipDiscID
  DiscogsReleaseID
  MusicbrainzAlbumID
  RutrackerID
  # Flags -->
  Compilation
  # Ripping & Encoding
  # FileType
  MediaType
  # SourceMedia
  # Source
  # URLs
  # AudioSourceWebpageURL
  # CommercialInformationURL
  # TrackArtistWebPageURL
  # Style
  Genre
  Mood
  Style
  # Miscellaneous -->
  Country
  Comments
  Description
  CopyrightMessage
  SyncedLyrics
  UnsyncedLyrics
  Language
end

APE_TAGS = {
  "ALBUM" => Tag::AlbumTitle,
  # ("DISCSUBTITLE", TagKey=>=>DiscSetSubtitle),
  # ("GROUPING", TagKey=>=>ContentGroup),
  "TITLE"               => Tag::TrackTitle,
  "SUBTITLE"            => Tag::TrackSubtitle,
  "ALBUMARTIST"         => Tag::AlbumArtist,
  "ARTIST"              => Tag::TrackArtist,
  "ARRANGER"            => Tag::Arranger,
  "WRITER"              => Tag::Writer,
  "COMPOSER"            => Tag::Composer,
  "CONDUCTOR"           => Tag::Conductor,
  "Enginee"             => Tag::Engineer,
  "LYRICIST"            => Tag::Lyricist,
  "LANGUAGE"            => Tag::Language,
  "MIXER"               => Tag::MixEngineer,
  "PERFORMER"           => Tag::Performer,
  "PRODUCER"            => Tag::Producer,
  "LABEL"               => Tag::Label,
  "MIXARTIST"           => Tag::RemixedBy,
  "DISC"                => Tag::DiscNumber,
  "TRACK"               => Tag::TrackNumber,
  "TRACKTOTAL"          => Tag::TrackTotal,
  "YEAR"                => Tag::Year,
  "ISRC"                => Tag::Isrc,
  "BARCODE"             => Tag::Barcode,
  "CATALOGNUMBER"       => Tag::CatalogueNumber,
  "DISCOGS_RELEASE_ID"  => Tag::DiscogsReleaseID,
  "MUSICBRAINZ_ALBUMID" => Tag::MusicbrainzAlbumID,
  "RUTRACKER"           => Tag::RutrackerID,
  "COMPILATION"         => Tag::Compilation,
  "MEDIA"               => Tag::MediaType,
  # ("SOURCEMEDIA", TagKey=>=>SourceMedia),
  "GENRE"          => Tag::Genre,
  "MOOD"           => Tag::Mood,
  "RELEASECOUNTRY" => Tag::Country,
  "COMMENT"        => Tag::Comments,
  "COPYRIGHT"      => Tag::CopyrightMessage,
}

ID3V2_TAGS = {
  "TALB" => Tag::AlbumTitle,
  # ("TSST", TagKey=>=>DiscSetSubtitle),
  # ("TIT1", TagKey=>=>ContentGroup),
  "TIT2"           => Tag::TrackTitle,
  "TIT3"           => Tag::TrackSubtitle,
  "TPE2"           => Tag::AlbumArtist,
  "TPE1"           => Tag::TrackArtist,
  "IPLS=>arranger" => Tag::Arranger,
  "TIPL=>arranger" => Tag::Arranger,
  "TEXT"           => Tag::AuthorWriter,
  "TCOM"           => Tag::Composer,
  "TPE3"           => Tag::Conductor,
  "IPLS=>engineer" => Tag::Engineer,
  "TIPL=>engineer" => Tag::Engineer,
  "IPLS"           => Tag::InvolvedPeople,
  "TIPL"           => Tag::InvolvedPeople,
  "IPLS=>DJ-mix"   => Tag::MixDJ,
  "TIPL=>DJ-mix"   => Tag::MixDJ,
  "IPLS=>mix"      => Tag::MixEngineer,
  "TIPL=>mix"      => Tag::MixEngineer,
  # ("TOPE", TagKey=>=>OriginalArtist),
  "TMCL"                      => Tag::Performer,
  "IPLS=>producer"            => Tag::Producer,
  "TIPL=>producer"            => Tag::Producer,
  "TPUB"                      => Tag::Publisher,
  "TXXX=>LABEL"               => Tag::Publisher,
  "TPE4"                      => Tag::RemixedBy,
  "TPOS"                      => Tag::DiscNumber,
  "TRCK"                      => Tag::TrackNumber,
  "TXXX=>TRACKTOTAL"          => Tag::TrackTotal,
  "TLEN"                      => Tag::Length,
  "TDRC"                      => Tag::ReleaseDate,
  "TDAT"                      => Tag::ReleaseDate,
  "TYER"                      => Tag::Year,
  "TORY"                      => Tag::OriginalReleaseDate,
  "TDOR"                      => Tag::OriginalReleaseDate,
  "TRDA"                      => Tag::RecordingDates,
  "TSRC"                      => Tag::Isrc,
  "DISCID"                    => Tag::DiscID,
  "TXXX=>BARCODE"             => Tag::Barcode,
  "TXXX=>CATALOGNUMBER"       => Tag::CatalogueNumber,
  "TXXX=>DISCOGS_RELEASE_ID"  => Tag::DiscogsReleaseID,
  "TXXX=>MUSICBRAINZ_ALBUMID" => Tag::MusicbrainzAlbumID,
  "TXXX=>RUTRACKER"           => Tag::RutrackerID,
  "TCMP"                      => Tag::Compilation,
  # ("TFLT", TagKey=>=>FileType),
  "TMED" => Tag::MediaType,
  # ("WOAS", TagKey=>=>AudioSourceWebpageURL),
  # ("WCOM", TagKey=>=>CommercialInformationURL),
  # ("WOAR", TagKey=>=>TrackArtistWebPageURL),
  "TCON"                 => Tag::Genre,
  "TMOO"                 => Tag::Mood,
  "TXXX=>RELEASECOUNTRY" => Tag::Country,
  "COMM"                 => Tag::Comments,
  "TCOP"                 => Tag::CopyrightMessage,
  "SYLT"                 => Tag::SyncedLyrics,
  "USLT"                 => Tag::UnsyncedLyrics,
  "TLAN"                 => Tag::Language,
}

VORBIS_TAGS = {
  "ALBUM" => Tag::AlbumTitle,
  # ("DISCSUBTITLE", Tag=>=>DiscSetSubtitle),
  # ("GROUPING", Tag=>=>ContentGroup),
  "TITLE"    => Tag::TrackTitle,
  "SUBTITLE" => Tag::TrackSubtitle,
  # ("VERSION", Tag=>=>Version),
  "ALBUMARTIST" => Tag::AlbumArtist,
  "ARTIST"      => Tag::TrackArtist,
  "ARRANGER"    => Tag::Arranger,
  "AUTHOR"      => Tag::AuthorWriter,
  "WRITER"      => Tag::Writer,
  "COMPOSER"    => Tag::Composer,
  "CONDUCTOR"   => Tag::Conductor,
  "ENGINEER"    => Tag::Engineer,
  "ENSEMBLE"    => Tag::Ensemble,
  "LYRICIST"    => Tag::Lyricist,
  "LANGUAGE"    => Tag::Language,
  "MIXER"       => Tag::MixEngineer,
  # ("ORGANIZATION", Tag=>=>Organisation),
  "PERFORMER"   => Tag::Performer,
  "PRODUCER"    => Tag::Producer,
  "PUBLISHER"   => Tag::Publisher,
  "LABEL"       => Tag::Label,
  "LABELNO"     => Tag::LabelNumber,
  "REMIXER"     => Tag::RemixedBy,
  "SOLOISTS"    => Tag::Soloists,
  "DISCNUMBER"  => Tag::DiscNumber,
  "DISCTOTAL"   => Tag::DiscTotal,
  "TOTALDISCS"  => Tag::DiscTotal,
  "TRACKNUMBER" => Tag::TrackNumber,
  "TRACKTOTAL"  => Tag::TrackTotal,
  "TOTALTRACKS" => Tag::TrackTotal,
  # ("PARTNUMBER", Tag=>=>PartNumber),
  "DATE"                => Tag::ReleaseDate,
  "ORIGINALDATE"        => Tag::OriginalReleaseDate,
  "ISRC"                => Tag::Isrc,
  "BARCODE"             => Tag::Barcode,
  "CATALOGNUMBER"       => Tag::CatalogueNumber,
  "UPC"                 => Tag::Upc,
  "DISCOGS_RELEASE_ID"  => Tag::DiscogsReleaseID,
  "MUSICBRAINZ_ALBUMID" => Tag::MusicbrainzAlbumID,
  "RUTRACKER"           => Tag::RutrackerID,
  "DISCID"              => Tag::DiscID,
  "ACCURATERIPDISCID"   => Tag::AccurateRipDiscID,
  "COMPILATION"         => Tag::Compilation,
  "MEDIA"               => Tag::MediaType,
  # ("SOURCEMEDIA", Tag=>=>SourceMedia),
  # ("SOURCE", Tag=>=>Source),
  "GENRE"          => Tag::Genre,
  "MOOD"           => Tag::Mood,
  "STYLE"          => Tag::Style,
  "RELEASECOUNTRY" => Tag::Country,
  "COMMENT"        => Tag::Comments,
  "DESCRIPTION"    => Tag::Description,
  "COPYRIGHT"      => Tag::CopyrightMessage,
}

class TagProcessor
  @native_tags : Hash(String, Tag)

  def initialize(@r : Release, @t : Track, @schema : Schema)
    @d = Disc.new(1)
    @l = Label.new
    @native_tags = case @schema
                   in Schema::ID3_V2         then ID3V2_TAGS
                   in Schema::VORBIS_COMMENT then VORBIS_TAGS
                   in Schema::APE_V2         then APE_TAGS
                   end
  end

  # Обработка переданных тегов с обновлением метаданных трека, альбома, релиза.
  # Необработанные теги возвращаются функцией обратно.
  def process
    @t.unprocessed.each do |k, v|
      native_key = @native_tags[k]?
      res = case native_key
            when Tag::AlbumTitle                       then @r.title = v
            when Tag::ReleaseDate, Tag::Year           then parse_and_set_year_from_date(k, v)
            when Tag::Genre, Tag::Style                then @t.genres << v
            when Tag::TrackTitle                       then @t.title = v
            when Tag::Publisher, Tag::Label            then @l.name = v
            when Tag::DiscNumber                       then set_track_disc_number(k, v)
            when Tag::DiscTotal                        then set_total_discs(k, v)
            when Tag::TrackTotal                       then set_total_tracks(k, v)
            when Tag::TrackNumber                      then set_track_pos_and_total_tracks(k, v)
            when Tag::AlbumArtist, Tag::Performer      then @r.add_role(v, "performer")
            when Tag::TrackArtist, Tag::InvolvedPeople then parse_and_add_actors(v)
            when Tag::Composer, Tag::Lyricist, Tag::AuthorWriter, Tag::Writer, Tag::Arranger
              @t.composition.add_role(v, k.downcase)
            when Tag::Conductor, Tag::Soloists, Tag::Engineer, Tag::Ensemble, Tag::MixDJ, Tag::MixEngineer,
                 Tag::Producer, Tag::RemixedBy
              @t.record.add_role(v, k.downcase)
            when Tag::CatalogueNumber, Tag::LabelNumber then @l.catnos << v
            when Tag::RutrackerID                       then @r.ids[ReleaseIdType::RUTRACKER] = v
            when Tag::Country
              @r.issues.actual.countries << v unless @r.issues.actual.countries.includes?(v)
            when Tag::MediaType then @d.fmt.media = Media.new(v)
            when Tag::TrackSubtitle
              # FIXME: если заголовок пустой и будет заполнен позже, то подзаголовок потеряется.
              @t.title = Track.complex_title(@t.title, v) ? @t.title : v
            when Tag::Length                            then @t.ainfo.duration_from_str = v
            when Tag::OriginalReleaseDate               then parse_and_set_original_year_from_date(k, v)
            when Tag::RecordingDates                    then @t.record.notes << v
            when Tag::DiscID                            then @d.disc_id = v
            when Tag::Barcode                           then @r.ids[ReleaseIdType::BARCODE] = v
            when Tag::Upc                               then @r.ids[ReleaseIdType::UPC] = v
            when Tag::AccurateRipDiscID                 then @r.ids[ReleaseIdType::ACCURATE_RIP] = v
            when Tag::DiscogsReleaseID                  then @r.ids[ReleaseIdType::DISCOGS] = v
            when Tag::MusicbrainzAlbumID                then @r.ids[ReleaseIdType::MUSICBRAINZ] = v
            when Tag::Compilation                       then @r.repeat = ReleaseRepeat::COMPILATION
            when Tag::Mood                              then set_moods(v)
            when Tag::Comments, Tag::Description        then @t.notes << v
            when Tag::CopyrightMessage                  then set_copyright(v)
            when Tag::SyncedLyrics, Tag::UnsyncedLyrics then set_lirycs(v, native_key == Tag::SyncedLyrics)
            when Tag::Language                          then @t.composition.lyrics.lng = v
              # FileType
              # SourceMedia
              # Source
              # AudioSourceWebpageURL
              # CommercialInformationURL
              # TrackArtistWebPageURL
              # DiscSetSubtitle
              # ContentGroup
              # Version
              # MusicianCredits
              # Organisation
              # OriginalArtist
              # PartNumber
              # when Tag::Isrc                              then @t.ids["isrc"] = v # FIXME
            end
      if res
        @t.unprocessed[k] = ""
      end
    end
    @t.unprocessed.reject! { |_, v| v.blank? }
    @r.discs << @d
    @r.issues.actual.add_label(@l)
  end

  private def set_total_discs(k : String, v : String)
    if n = v.to_i?
      @r.total_discs = n
      return true
    end
    false
  end

  private def set_total_tracks(k : String, v : String)
    if n = v.to_i?
      @r.total_tracks = n
    end
    true
  end

  private def set_moods(v : String)
    v.gsub(%r{[,;\/\(\)\[\]&]}, ' ').split.each do |mood_str|
      @t.moods << Mood.parse(mood_str)
    end
    true
  end

  private def set_copyright(v : String)
    unless @l.name.empty?
      @l.name = v.delete('@').delete('\u2122').strip
    end
    true
  end

  private def set_lirycs(v : String, is_synced : Bool)
    @t.composition.lyrics.text = v
    @t.composition.lyrics.is_synced = is_synced
    true
  end

  # Обработка строк формата "6/12", где 6 - позиция трека, 12 - общее число треков.
  private def set_track_pos_and_total_tracks(k : String, v : String)
    flds = v.split('/')
    flds_len = flds.size
    if (1..2).includes?(flds_len)
      @t.position = Track.normalize_pos(flds[0])
    end
    if flds_len == 2
      if n = flds[1].to_i?
        @r.total_tracks = n
      else
        return false
      end
    end
    true
  end

  private def parse_date(v : String)
    if year = v.to_i?
      year
    else
      Time::Format::ISO_8601_DATE.parse(v).year
    end
  rescue
    nil
  end

  # Разбор timestamp ISO 8601 (yyyy-MM-ddTHH:mm:ss) или ее подстроки для Release.Year.
  private def parse_and_set_year_from_date(k : String, v : String)
    if year = parse_date(v)
      @r.issues.actual.year = year
    else
      return false
    end
    true
  end

  # Разбор timestamp ISO 8601 (yyyy-MM-ddTHH:mm:ss) / подстроки для Release.Album.Year
  private def parse_and_set_original_year_from_date(k : String, v : String)
    if year = parse_date(v)
      @r.issues.ancestor.year = year
    else
      return false
    end
    true
  end

  # Возможный формат {soloists,conductor,orchestra}, разделенный ';' с указанием
  # через иной разделитель роли актора или простой список имен через ','.
  private def parse_and_add_actors(v : String)
    parts = v.split(";") # Разделяем по ';' для обработки ролей
    if parts.size == 1
      # Простой список имён через запятую
      parts[0].split(",").each do |nm|
        @r.add_role(nm.strip)
      end
    else
      parts.each do |ai|
        roles = ai.gsub(/[,;\/\(\)\[\]&]/, ',').split(',')
        if !roles.empty?
          name = roles.first?.try(&.strip) || ""
          remaining_roles = roles[1..-1] || [] of String
          remaining_roles.each do |role|
            @t.record.add_role(name, role.strip) if !role.strip.empty? # FIXME: не эффективно
          end
          @r.add_actor(name, "", "") unless name.empty?
        else
          @r.add_actor(ai.strip, "", "")
        end
      end
    end
    true
  end

  # TODO: Разобрать номер трека и, при наличии номер диска, установить его по примеру
  # set_disc_num(track::disc_num_by_track_pos(dsf.tr.position()));
  private def set_track_disc_number(k : String, v : String)
    if dn = v.to_i?
      @t.disc_num = dn
    else
      return false
    end
    true
  end
end
