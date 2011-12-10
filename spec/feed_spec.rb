require_relative 'spec_helper.rb'

describe FeedNormalizer::Feed do
  let(:feed) {
    wrapper = double("TestWrapper")
    parser = double("TestParser")
    parser.stub!(:to_s).and_return("called TestParser.to_s")
    wrapper.stub!(:parser).and_return(parser)

    FeedNormalizer::Feed.new(wrapper)
  }

  it "renders a RSS feed" do
    feed.build_rss!.should == '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"><channel><title></title><link></link><description></description><ttl>60</ttl></channel></rss>'
  end
end
