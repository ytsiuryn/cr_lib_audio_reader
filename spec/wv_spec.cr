require "spec"
require "core"
require "../src/wv"

it "WavPack mono track parsing" do
  r = Release.new
  wv = WavPack.new("spec/data/wv/440_hz_mono.wv")
  wv.apply_to(r)
  # r.block_samples.should eq 22050
  #  @channel_mode=0,
  #  @false_stereo=0,
  # r.pcm_or_dsd.should eq 0 # PCM
  #  @sampling_rate=0,
  #  @stereo_mode=0,
  t = r.tracks[-1]
  t.title.should eq "test_track_title"
  t.genres.should contain "test_genre"
  t.position.should eq "03"
  t.notes.should contain "test_notes"
  t.composition.roles.has_key?("test_composer").should be_true
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
