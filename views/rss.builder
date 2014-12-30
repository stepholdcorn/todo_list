xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "Todo"
		xml.link request.url.chomp request.path_info
		
		@notes.each do |note|
			xml.item do
				xml.title h note.content
				xml.link "#{request.url.chomp request.path_info}/#{note.id }"
				xml.guid "#{request.url.chomp request.path_info}/#{note.id }"
				xml.PubDate Time.parse(note.created_at.to_s).rfc822
			end
		end
	end
end
