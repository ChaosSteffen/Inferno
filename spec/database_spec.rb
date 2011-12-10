require_relative 'spec_helper.rb'

describe Database do
  let(:uri) { "/" }
  let(:document) {
    { :my => "data" }
  }

  describe :count_for_guid! do
    let(:guid) { "http://example.com/foo/bar" }
    let(:revision) { "0123456789abcdef" }

    before(:each) do
      Database.stub!(:item_uri).and_return(uri)
      Database.stub!(:read).and_return({"_rev" => revision, "count" => 1})
      Database.stub!(:update)
    end

    it "gets uri for guid" do
      Database.should_receive(:item_uri).and_return("/foo")

      Database.count_for_guid!(guid)
    end

    it "gets old count" do
      Database.should_receive(:read).and_return({"_rev" => revision, "count" => 1})

      Database.count_for_guid!(guid)
    end

    it "increases counts" do
      Database.should_receive(:read).and_return({"_rev" => revision, "count" => 1})
      Database.should_receive(:update).with(uri, revision, {"count" => 2})

      Database.count_for_guid!(guid)
    end

    it "creates new document for new counts" do
      Database.should_receive(:read).and_return(nil)
      Database.should_receive(:create).with(uri, {"count" => 1})

      Database.count_for_guid!(guid)
    end
  end

  describe :add_feed! do
    let(:slug) { "foo" }
    let(:url) { "http://example.com/rss" }
    let(:revision) { "0123456789abcdef" }

    it "requires slug and url" do
      expect {
        Database.add_feed!
      }.to raise_error(ArgumentError)
    end

    it "creates a feed document" do
      Database.should_receive(:create).with("/feeds/#{slug}", { "url" => url })

      Database.add_feed!(slug, url)
    end
  end

  describe :create do
    it "creates new documents" do
      RestClient.should_receive(:put).with(uri, document.to_json)

      Database.create(uri, document)
    end

    it "is protected from adding revisions" do
      expect {
        Database.create(uri, document.merge({"_rev" => "123"}))
      }.to raise_error("CREATE requests have no revisions")

      expect {
        Database.create(uri, document.merge({:_rev => "123"}))
      }.to raise_error("CREATE requests have no revisions")
    end
  end

  describe :read do
    it "reads old docemnts" do
      RestClient.should_receive(:get).with(uri).and_return('{"foo": "bar"}')

      Database.read(uri).should == { "foo" => "bar" }
    end

    it "detects non-existing documents" do
      RestClient.should_receive(:get).with(uri) {
        raise RestClient::ResourceNotFound
      }

      Database.read(uri).should == nil
    end
  end

  describe :update do
    it "updates old docemnts" do
      revision = "0123456789abcdef"
      RestClient.should_receive(:put).with(uri, document.merge({:_rev => revision}).to_json)

      Database.update(uri, revision, document)
    end
  end

  describe :item_uri do
    it "url-escapes the guid" do
      Database.send(:item_uri, "http://example.com/foo/bar").should match(/\/http%3A%2F%2Fexample.com%2Ffoo%2Fbar$/)
    end
  end

end
