class FeedNormalizer::Feed
  def build_rss!
    xml = Builder::XmlMarkup.new
    xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
      xml.channel do
        xml.title(channel.title)
        xml.link(channel.url)
        xml.description channel.description

        # optionals
        xml.copyright copyright if copyright
        xml.managingEditor author if author
        xml.lastBuildDate last_updated if last_updated
        xml.image image if image
        xml.generator generator if generator

        # configured by user
        xml.ttl 60

        for item in channel.items
          xml.item do
            xml.title(item.title)
            xml.description(item.description)
            xml.pubDate(item.date_published.rfc2822)
            xml.guid(item.id)
            xml.link(item.url)
          end
        end
      end
    end
  end

end
