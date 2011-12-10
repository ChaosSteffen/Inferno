class Database
  @@connection_url = "#{ENV['CLOUDANT_URL']}"

  def self.count_for_guid! guid
    uri = item_uri(guid)

    if data = read(uri)
      update(uri, data["_rev"], {
        "count" => data["count"]+1
      })
    else
      create(uri, { "count" => 1})
    end
  end

  def self.add_feed! slug, url
    uri = feed_uri(slug)
    create(uri, {"url" => url})
  end

  def self.get_feed slug
    uri = feed_uri(slug)
    read(uri)
  end

  def self.create uri, data={}
    raise "CREATE requests have no revisions" if data.delete("_rev") or data.delete(:_rev) # avoid mixing CREATE and UPDATE requests
    RestClient.put(uri, data.to_json)
  end

  def self.read uri
    raw_data = RestClient.get(uri)

    return JSON.parse(raw_data)
  rescue RestClient::ResourceNotFound
    return nil
  end

  def self.update uri, revision, data={}
    data.merge!("_rev" => revision)
    RestClient.put(uri, data.to_json)
  end

private

  def self.feed_uri slug
    return @@connection_url + "/feeds/#{slug}"
  end

  def self.item_uri guid
    return @@connection_url + '/items/' + CGI.escape(guid)
  end

end
