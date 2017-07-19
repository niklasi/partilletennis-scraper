require "json"
require "nokogiri"
require "open-uri"
require "cgi"
require "./helpers"

task :default => [:all_matches, :all_teams]


task :all_matches do
  matches = Array.new
  for division in 1..3 do
    schemaDiv = "Schemadiv.#{division}"
    doc = Nokogiri::HTML(open("http://idrottonline.se/ForeningenPartilleTennis-Tennis/foretagstennis/#{schemaDiv}/"))
    rows = doc.css('.PageBodyDiv table:last tbody tr')
    rows.each do |row|
      cells = row.css('td')
      home_team, away_team = cells[2].content.gsub("\r\n", "").strip.split('-', 2)
      next if (home_team == 'Lag')
      date = cells[0].content.gsub("\r\n", "").strip
      time = cells[1].content.gsub("\r\n", "").strip
      next if date == time
      lanes = cells[3].content.gsub("\r\n", "").strip.gsub(/(\s|\u00A0)+/, ' ')
      currentTime = Time.new

      date = "#{currentTime.year}-#{get_month(date)}-#{get_day(date)}"
      matches << {home_team: home_team, away_team: away_team, date: date, time: time, lanes: lanes, division: division}

    end
  end

  puts matches.to_json
end

task :all_teams do
  teams = Array.new
  for division in 1..3 do
    schemaDiv = "Schemadiv.#{division}"
    doc = Nokogiri::HTML(open("http://idrottonline.se/ForeningenPartilleTennis-Tennis/foretagstennis/#{schemaDiv}/"))
    rows = doc.css('.PageBodyDiv table:first tbody tr')
    rows.each do |row|
      cellContainers = row.css('td')
      cells = cellContainers
      next if cells[1].content.strip.gsub("\r\n","") == 'Lag'
      team_ranking = cells[0].content.strip
      team_name = cells[1].content.strip.gsub("&nbsp;","")
      contact = cells[2].content.strip
      phone = cells[3].content.strip
      next if team_name == phone
      email_cell = cellContainers[4].css('p img')
      email = ''
      email_cell = cellContainers[4].css('p img')
      if email_cell[0] == nil
        email_cell = cellContainers[4].css('h2 img')
      end

      if email_cell[0] != nil
        email = email_cell[0].attributes["src"].value.gsub("/IdrottOnlineKlubb/Partille/foreningenpartilletennis-tennis/foretagstennis/#{schemaDiv}/EmailEncoderEmbed.aspx?it=", "")	
        email = decode_email(CGI.unescape(email)).sub('mailto:', '').strip
      end

      teams << ({
        :team_name => scrub(team_name), 
        :division => division,
        :team_ranking => scrub(team_ranking), 
        :contact => scrub(contact), 
        :phone => scrub(phone),
        :email => scrub(email)
      })
    end
  end

  puts teams.to_json
end
