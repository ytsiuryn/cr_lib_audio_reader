require "spec"
require "core"
require "../src/dsf"

describe DSF do
  it "#fill" do
    r = Release.new
    dsf = DSF.new("spec/data/dsf/440_hz_mono.dsf")
    dsf.apply_to(r)
    
    t = r.tracks[-1]
    
    t.ainfo.duration.should eq 500
    t.ainfo.channels.should eq 1
    t.ainfo.samplesize.should eq 1
    t.ainfo.samplerate.should eq 2822400
    # t.ainfo.avg_bitrate.should eq 2822
    
    t.position.should eq "03"
    t.genres.should contain "test_genre"
    t.notes.should contain "test_notes"
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
    r.pictures[0].url.should eq "folder.jpg"
    r.pictures[0].data.size.should eq 697
    r.pictures[1].pict_type.should eq PictType::COVER_BACK
    r.pictures[1].md.mime.should eq "image/jpeg"
    r.pictures[1].url.should eq "back.png"
    r.pictures[1].data.size.should eq 4266
    r.issues.actual.catnos.should contain "test_catno"
    r.issues.actual.label("test_label").should be_a(Label)
    r.issues.actual.countries.should contain "test_country"
    r.ids[ReleaseIdType::DISCOGS].should eq "123456789"
    r.ids[ReleaseIdType::RUTRACKER].should eq "123456789"
  end
end
