require "goon_model_gen/golang/datastore_supported"

RSpec.describe GoonModelGen::Golang::DatastoreSupported do
  context :packages do
    subject{ GoonModelGen::Golang::DatastoreSupported.packages }

    it "can find appengine.GeoPoint" do
      t = subject.type_for("appengine.GeoPoint")
      expect(t).not_to be_nil
      expect(t.package.path).to eq "google.golang.org/appengine"
      expect(t.package.basename).to eq "appengine"
      expect(t.qualified_name).to eq "appengine.GeoPoint"
    end

    it "can find *datastore.Key" do
      t = subject.type_for("*datastore.Key")
      expect(t.target).not_to be_nil
      expect(t.target.package.path).to eq "google.golang.org/appengine/datastore"
      expect(t.target.package.basename).to eq "datastore"
      expect(t.target.qualified_name).to eq "datastore.Key"

      expect(t).not_to be_nil
      expect(t.package.path).to eq "google.golang.org/appengine/datastore"
      expect(t.package.basename).to eq "datastore"
      expect(t.qualified_name).to eq "*datastore.Key"

    end
  end
end
