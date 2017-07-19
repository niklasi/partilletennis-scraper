require "json"
require "nokogiri"
require "open-uri"
require "cgi"
require "./helpers"

namespace :foretagstennis do
  desc "Get both matches and teams"
  task :all => ["foretagstennis:matches", "foretagstennis:teams"]

  task :fetch do
    @docs = Hash.new
    for division in 1..3 do
      @docs[division] = Nokogiri::HTML(open("http://idrottonline.se/ForeningenPartilleTennis-Tennis/foretagstennis/Schemadiv.#{division}/"))
    end
  end

  desc "Get all matches"
  task :matches => :fetch do
    matches = Array.new
    for division in 1..3 do
      doc = @docs[division] 
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

  desc "Get all teams"
  task :teams => :fetch do
    teams = Array.new
    for division in 1..3 do
      doc = @docs[division]
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
        email = ''
        email_cell = cellContainers[4].css('p img')
        if email_cell[0] == nil
          email_cell = cellContainers[4].css('h2 img')
        end

        if email_cell[0] != nil
          email = email_cell[0].attributes["src"].value.gsub("/IdrottOnlineKlubb/Partille/foreningenpartilletennis-tennis/foretagstennis/Schemadiv.#{division}/EmailEncoderEmbed.aspx?it=", "")	
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
end

namespace :motionserier do
  
  task :fetch do
    @docs = Hash.new
		# for division in ['Damsingel', 'HerrsingelDiv1', 'HerrsingelDiv2', 'HerrsingelDiv3'] do
    for division in ['HerrsingelDiv1', 'HerrsingelDiv2', 'HerrsingelDiv3'] do
      @docs[division] = Nokogiri::HTML(open("http://idrottonline.se/ForeningenPartilleTennis-Tennis/Motionsserier/#{division}/"))
    end
  end

  desc "Get alll matches"
  task :matches => :fetch do
    matches = Array.new
		# for division in ['Damsingel', 'HerrsingelDiv1', 'HerrsingelDiv2', 'HerrsingelDiv3'] do
		for division in ['HerrsingelDiv1', 'HerrsingelDiv2', 'HerrsingelDiv3'] do
      doc = @docs[division]
        rows = doc.css('.PageBodyDiv table:last tbody tr')
        rows.each do |row|
          cells = row.css('td')
          next if cells.length < 3
          date = cells[0].content.gsub("\r\n", "").strip
          time = cells[1].content.gsub("\r\n", "").strip
          home_team_index = 3
          away_team_index = 4
          lanes_index = 2
          if (division == 'Damsingel') then
            home_team_index = 2
            away_team_index = 3
            lanes_index = 4
          end
          home_team = cells[home_team_index].content.gsub("\r\n", "").strip
          away_team = cells[away_team_index].content.gsub("\r\n", "").strip
          next if (time == 'Tid')
          next if date == time
          lanes = cells[lanes_index].content.gsub("\r\n", "").strip.gsub(/(\s|\u00A0)+/, ' ')
          matches << {home_team: home_team, away_team: away_team, date: date, time: time, lanes: lanes, division: division}
          
        end
		end

    puts matches.to_json
	end

  desc "Get all teams"
  task :teams => :fetch do
    teams = Array.new
		# for division in ['Damsingel', 'HerrsingelDiv1', 'HerrsingelDiv2', 'HerrsingelDiv3'] do
		for division in ['HerrsingelDiv1', 'HerrsingelDiv2', 'HerrsingelDiv3'] do
			doc = @docs[division]

      rows = doc.css('.PageBodyDiv table:first tbody tr')
      rows.each do |row|
        cellContainers = row.css('td')
        cells = cellContainers
        offset = 0
        next if cells.length < 3
        offset = 1 if cells.length > 5
        next if cells[1 + offset].content.strip.gsub("\r\n","") == 'Lag'
        next if cells[1 + offset].content.strip.gsub("\r\n","") == 'Namn'
        team_ranking = cells[0 + offset].content.strip
        next if team_ranking.to_i == 0
        team_name = cells[1 + offset].content.strip.gsub("&nbsp;", "").gsub(/(\s|\u00A0)+/, ' ')
        email =  get_email(cells[2 + offset].css('p img'), division)
        phone = cells[3 + offset].content.strip
        phone = cells[4 + offset].content.strip if (cells.length > 4)
        phone = "0721-843748" if (team_name == "Johan Hellström" and phone.length < 2)

        @teams[team_ranking] = {:team_name => team_name, :contact => '', :phone => phone, :email => email}

			  teams << ({
          :team_name => scrub(team_name),
          :division => division,
          :team_ranking => scrub(team_ranking), 
          :contact => '',
          :phone => scrub(phone),
          :email => scrub(email)
        })
      end
		end

    puts teams.to_json
  end

  def get_email(email_cell, division)
    email = ''
    if email_cell[0] == nil
      puts email_cell
      email_cell = cellContainers[2].css('h2 img')
    end

    if email_cell[0] != nil
      email = email_cell[0].attributes["src"].value.gsub("/IdrottOnlineKlubb/Partille/foreningenpartilletennis-tennis/Motionsserier/#{division}/EmailEncoderEmbed.aspx?it=", "")	
      email = decode_email(CGI.unescape(email)).sub('mailto:', '').strip
    end
    email = 'kerstinblundin@gmail.com' if email == 'erstinblundin@gmail.com'
    email = 'ewabazar@yahoo.com' if email == 'wabazar@yahoo.com'
    email
  end
end

