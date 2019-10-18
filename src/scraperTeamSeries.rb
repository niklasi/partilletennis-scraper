require "json"
require "nokogiri"
require "open-uri"
require "cgi"
require "./helpers"

module TeamSeries
  def self.load (division)
    docs = Hash.new
    docs[division] = Nokogiri::HTML(open("https://idrottonline.se/ForeningenPartilleTennis-Tennis/lagserien/Schemadiv.#{division}/"))

    teams = Array.new
    matches = Array.new
    docs.each do |division, doc|
      createTeam(division, doc) do |team|
        teams << team
      end
      createMatches(division, doc) do |match|
        matches << match
      end
    end

    return {:teams => teams, :matches => matches}
  end

  def self.createTeam (division, doc)
    rows = doc.css('.PageBodyDiv table:first tbody tr')
    rows.each do |row|
      cellContainers = row.css('td')
      cells = cellContainers

      next if cells[1].content.wash == 'Lag'

      team_ranking = cells[0].content.wash
      team_name = cells[1].content.wash
      contact = cells[2].content.wash
      phone = cells[3].content.wash

      next if team_name == phone

      email_cell = cellContainers[4].css('p img')
      email_cell = cellContainers[4].css('h2 img') if email_cell[0] == nil

      email = ''
      email = get_email email_cell[0] if email_cell[0] != nil

      yield ({
        :team_name => team_name,
        :division => division,
        :team_ranking => team_ranking,
        :contact => contact,
        :phone => phone,
        :email => email
      })
    end
  end

  def self.createMatches (division, doc)
    rows = doc.css('.PageBodyDiv table:last tbody tr')
    rows.each do |row|
      cells = row.css('td')
      home_team, away_team = cells[2].content.wash.split('-', 2)
      next if (home_team == 'Lag')
      date = cells[0].content.wash

      time = cells[1].content.wash
      next if date == time
      lanes = cells[3].content.wash
      currentTime = Time.new

      date = "#{currentTime.year}-#{get_month(date)}-#{get_day(date)}"

      yield ({
        home_team: home_team,
        away_team: away_team,
        date: date,
        time: time,
        lanes: lanes,
        division: division
      })
    end
  end

  def self.get_email (email_cell)
    email = email_cell.attributes["src"].value
    index = email.index("?it=")
    email = email[index + 4, email.length]
    decode_email(CGI.unescape(email)).sub('mailto:', '').wash
  end
end
