require "json"
require "nokogiri"
require "open-uri"
require "cgi"
require "./helpers"

module TeamSeries
  def self.load division
    divisionUrls = Hash.new
    divisionUrls["1"] = "https://docs.google.com/spreadsheets/d/1eN5m3CURmNIOItQwvub7hOvGRMA_6MbdVvSgDVTdcGI/edit#gid=0"
    divisionUrls["2"] = "https://docs.google.com/spreadsheets/d/1_drc1QFADs1gVN9wZvjTfqExlgJ0svwgAkj_z75EKhs/edit#gid=0"
    divisionUrls["3"] = "https://docs.google.com/spreadsheets/d/1nN4zdmSOZm3crniavPbna3v6hd6LxgkU_OAipb0Ba4o/edit#gid=0"

    docs = Hash.new
    # docs[division] = Nokogiri::HTML(open("https://idrottonline.se/ForeningenPartilleTennis-Tennis/lagserien/Schemadiv.#{division}/"))
    docs[division] = Nokogiri::HTML(open(divisionUrls[division]))

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

  def self.createTeam division, doc
    # rows = doc.css('.PageBodyDiv table:first tbody tr')
    # rows = doc.css('.PageBodyDiv table:first tbody tr')
    # print all teams
    # File.foreach("teams.txt") { |line| yield ({:team_name => line}) }
    teams = File.open("teamseries_teams_div_#{division}.txt", "rb:UTF-8")
    teams_data = teams.readlines.map(&:chomp)
    teams_data.each do |team_data|
      team = team_data.split("\t")

      yield ({
        :team_name => team[1],
        :division => division,
        :team_ranking => team[0],
        :contact => team[2],
        :phone => team[3],
        :email => team[4]
      })
    end
# ["user1", "user2", "user3"]
    # rows.each do |row|
    #   cellContainers = row.css('td')
    #   cells = cellContainers
    #
    #   next if cells[1].content.wash == 'Lag'
    #
    #   team_ranking = cells[0].content.wash
    #   team_name = cells[1].content.wash
    #   contact = cells[2].content.wash
    #   phone = cells[3].content.wash
    #
    #   next if team_name == phone
    #
    #   email_cell = cellContainers[4].css('p img')
    #   email_cell = cellContainers[4].css('h2 img') if email_cell[0] == nil
    #
    #   email = ''
    #   email = get_email email_cell[0] if email_cell[0] != nil

    #   yield ({
    #     :team_name => team_name,
    #     :division => division,
    #     :team_ranking => team_ranking,
    #     :contact => contact,
    #     :phone => phone,
    #     :email => email
    #   })
    # end
  end

  def self.createMatches (division, doc)
    matches = File.open("teamseries_matches_div_#{division}.txt", "rb:UTF-8")
    matches_data = matches.readlines.map(&:chomp)
    matches_data.each do |match_data|
      match = match_data.split("\t")
      teams = match[2].split("-") 
      yield ({
        home_team: teams[0],
        away_team: teams[1],
        date: match[0],
        time: match[1],
        lanes: match[3],
        division: division
      })
  end
    # rows = doc.css('.PageBodyDiv table:last tbody tr')
    # rows.each do |row|
    #   cells = row.css('td')
    #   home_team, away_team = cells[2].content.wash.split('-', 2)
    #   next if (home_team == 'Lag')
    #   date = cells[0].content.wash
    #
    #   time = cells[1].content.wash
    #   next if date == time
    #   lanes = cells[3].content.wash
    #   currentTime = Time.new
    #
    #   date = "#{currentTime.year}-#{get_month(date)}-#{get_day(date)}"
    #
    #   yield ({
    #     home_team: home_team,
    #     away_team: away_team,
    #     date: date,
    #     time: time,
    #     lanes: lanes,
    #     division: division
    #   })
    # end
  end

  def self.get_email (email_cell)
    email = email_cell.attributes["src"].value
    index = email.index("?it=")
    email = email[index + 4, email.length]
    decode_email(CGI.unescape(email)).sub('mailto:', '').wash
  end
end
