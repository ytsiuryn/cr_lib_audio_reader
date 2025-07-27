require "spec"
require "core"
require "../src/flac"

describe FLAC do
  it "#fill" do
    r = Release.new
    flac = FLAC.new("spec/data/flac/440_hz_mono.flac")
    flac.apply_to(r)

    t = r.tracks[-1]
    t.title.should eq "test_track_title"
    t.position.should eq "03"
    t.genres.should contain "test_genre"
    t.notes.should contain "test_notes"
    t.ainfo.avg_bitrate.should eq 152
    t.composition.roles.has_key?("test_composer").should be_true
    t.unprocessed.size.should eq 0

    r.title.should eq "test_album_title"
    r.total_tracks.should eq 10
    r.issues.actual.year.should eq 2000
    r.roles["test_track_artist"].should eq Set{"performer"}
    r.roles["test_performer"].should eq Set{"performer"}
    r.pictures.size.should eq 2
    r.pictures[0].pict_type.should eq PictType::COVER_FRONT
    r.pictures[0].md.mime.should eq "image/jpeg"
    r.pictures[0].url.should eq "folder.png"
    r.pictures[0].md.width.should eq 400
    r.pictures[0].md.height.should eq 400
    r.pictures[0].data.size.should eq 697
    r.issues.actual.catnos.should contain "test_catno"
    r.issues.actual.label("test_label").should be_a(Label)
    r.issues.actual.countries.should contain "test_country"
    r.ids[ReleaseIdType::DISCOGS].should eq "123456789"
    r.ids[ReleaseIdType::RUTRACKER].should eq "123456789"
  end
end

# it "processes tags fast" do
#   tags = {
#     "TITLE"  => "Test Song",
#     "ARTIST" => "Band (vocals), Guest (guitar)",
#     "DATE"   => "2023",
#     "GENRE"  => "Rock;Metal",
#   }

#   r = Release.new
#   t = Track.new(path = "spec/data/flac/440_hz_mono.flac")

#   time = Time.measure do
#     1000.times { TagProcessor.new(r, t, Schema::VORBIS_COMMENT, tags).process }
#   end

#   pp! "Processed 1000 iterations in #{time.total_milliseconds}ms"
#   time.total_microseconds.should be < 5000.0 # Целевое время
# end
