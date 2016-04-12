def process_gazette_notice(gn)
  assertions = gn.created_assertions
  case assertions.size
  when 0
    puts "Gazette notice #{gn.id} has no assertions, skipping"
    return
  when 1
  else
    raise "Gazette notice #{gn.id} has #{assertions.size} assertions"
  end

  assertion = assertions[0]

  gnd = assertion.details

  companies_data = assertion.companies.map {|c|
    {
      jurisdiction_code: c.jurisdiction_code,
      company_number: c.company_number,
    }
  }

  {
    gazette_notice_id: gn.id,
    retrieved_at: gn.retrieved_at,
    stash: gn.stash,
    gnd: gnd.attributes,
    companies: companies_data,
  }
end

total = 0
successful = 0

outfile = File.open("/oc/tmp/dumped-gazette-notices.json", "w")
logfile = File.open("/oc/tmp/dumped-gazette-notices.log", "w")

STDOUT.puts "#{Time.now} starting"

GazetteNotice.includes(:created_assertions).find_each do |gn|
  begin
    total += 1
    record = process_gazette_notice(gn)
    outfile.puts record.to_json
    successful += 1
    logfile.puts "success: #{gn.id}"
  rescue Exception => e
    logfile.puts "failed: #{gn.id}"
  end
 
  if total % 10_000 == 0
    STDOUT.puts "#{successful} / #{total}"
    STDOUT.flush
  end
end
