require 'json'

notice_names = JSON.parse(File.read("codes.json"))

STDIN.each_line do |line|
  begin
    raw_record = JSON.parse(line)
  rescue JSON::ParserError
    STDERR.puts "Could not parse: #{line}"
    next
  end

  companies = raw_record["companies"].map {|company|
    {
      entity_type: "company",
      entity_properties: company,
    }
  }

  if (gazette_name = raw_record["stash"]["gazette_name"])
    edition_id = "The #{gazette_name[0].upcase}#{gazette_name[1..-1]} Gazette"
  else
    edition_id = nil
  end

  if (notice_code = raw_record["gnd"]["notice_code"])
    notice_name = notice_names[notice_code]
  else
    notice_name = nil
  end

  uid = raw_record["stash"]["uid"] || "#{raw_record["stash"]["issue_number"]}/#{raw_record["stash"]["notice_number"]}"

  if raw_record["gnd"]["html"].nil?
    STDERR.puts "No body for #{uid}"
    next
  end

  record = {
    identifier: uid,
    uid: uid,
    date_published: raw_record["gnd"]["publication_date"],
    subjects: companies,
    about: {
      type: 'other',
      body: {
        value: raw_record["gnd"]["html"],
        media_type: 'text/html',
      },
    },
    issue: {
      publication: {
        publisher: {
          name: 'The Stationery Office Limited',
          url: 'http://www.tso.co.uk/',
          media_type: 'text/html',
        },
        jurisdiction_code: 'gb',
        title: 'The Gazette',
        url: 'https://www.thegazette.co.uk/',
        media_type: 'text/html',
      },
      edition_id: edition_id,
    },
    url: raw_record["gnd"]["uri"],
    media_type: 'text/html',
    source_url: raw_record["gnd"]["uri"],
    sample_date: raw_record["retrieved_at"],
    retrieved_at: raw_record["retrieved_at"],
    confidence: 'MEDIUM',
    other_attributes: {
      gazette_notice_id: raw_record["gazette_notice_id"]
    }
  }

  if notice_name && notice_code
    record[:about][:classification] = [{
      name: notice_name,
      code: notice_code,
    }]
  end

  puts record.to_json
end
