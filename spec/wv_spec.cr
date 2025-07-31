require "spec"
require "core"
require "../src/wv"

describe WavPack do
  it "#apply_to (need all pictures)" do
    r = Release.new
    wv = WavPack.new("spec/data/wv/440_hz_mono.wv")
    wv.apply_to(r)
    t = r.tracks[-1]
    t.title.should eq "test_track_title"
    t.genres.should contain "test_genre"
    t.position.should eq "03"
    t.notes.should contain "test_notes"
    t.composition.roles.has_key?("test_composer").should be_true
    t.unprocessed.size.should eq 0
    # t.ainfo.samplerate.should eq 22_050
    # t.ainfo.channels.should eq 1

    r.title.should eq "test_album_title"
    r.total_tracks.should eq 10
    r.roles["test_track_artist"].should eq Set{"performer"}
    r.roles["test_performer"].should eq Set{"performer"}
    r.issues.actual.year.should eq 2000
    r.issues.actual.catnos.should contain "test_catno"
    r.issues.actual.label("test_label").should be_a(Label)
    r.issues.actual.countries.should contain "test_country"
    r.ids[ReleaseIdType::DISCOGS].should eq "123456789"
    r.ids[ReleaseIdType::RUTRACKER].should eq "123456789"
    r.pictures.size.should eq 2
    r.pictures[0].pict_type.should eq PictType::COVER_BACK
    r.pictures[0].url.should eq "back.png"
    r.pictures[1].pict_type.should eq PictType::COVER_FRONT
    r.pictures[1].url.should eq "backcolor.png"
    # pp! t.ainfo.samplesize, t.ainfo.channels, t.ainfo.samplerate
  end

  it "#apply_to (there are all pictures)" do
    r = Release.new
    r.pictures.hashes << "e3dce5a4c20e7f495cfb6d39a90513c048c3e0d6d63b78cb20495ae4fdda7b4a"
    r.pictures.hashes << "770d292cb7e348f40b675516c34a89a7263a07d0f5b2b6d1acd2d0f5040e1b28"
    wv = WavPack.new("spec/data/wv/440_hz_mono.wv")
    wv.apply_to(r)
    r.pictures.size.should eq 0
  end
end
