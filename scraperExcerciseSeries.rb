require "json"
require "nokogiri"
require "open-uri"
require "cgi"
require "./helpers"

module ExcerciseSeries
  def self.load (division)
    docs = Hash.new
    docs[division] = Nokogiri::HTML(open("https://idrottonline.se/ForeningenPartilleTennis-Tennis/Motionsserier/#{division}/"))

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
      cells = Array.new
      row.css('td').each do |cell|

        cell_content = ''

        email_cells = cell.css('p img')
        if (email_cells.length > 0)
          emails = Array.new
          email_cells.each do |email_cell|
            begin
              emails.push get_email(email_cell)
            rescue
              emails.push 'ingela.eliasson@kungsbacka.se'
            end
          end
          cell_content = emails.join(' / ')
        else
          cell_content = cell.content.wash 
          paragraphs = Array.new
          cell.css('p').each do |paragraph|
            paragraphs.push paragraph.content.wash
          end
          cell_content = paragraphs.join(' / ') if paragraphs.length > 0
        end
        cells << cell_content if cell_content != ''
      end

      next if cells[0] == 'Namn'
      next if cells[0].to_i == 0
      next if cells[0].to_i == 2019

      # division = 'DamdubbelDiv2'
      yield ({
        :team_name => cells[1],
        :division => division,
        :team_ranking => cells[0].to_i.to_s,
        :contact => '',
        :phone => cells[cells.length - 1],
        :email => cells[2]
      })
    end
  end

  def self.createMatches (division, doc)
    rows = doc.css('.PageBodyDiv table:nth(2) tbody tr')
    # rows = doc.css('.PageBodyDiv div div table tbody tr')
    rows.each do |row|
      cells = row.css('td')

      next if cells.length < 3

      date = cells[0].content.wash
      time = cells[1].content.wash
      home_team_index = 3
      away_team_index = 4
      lanes_index = 2
      if (division.start_with? 'Mixeddubbel')
        next if date == 'reservtid'
        team_index = 3
        teams = cells[team_index].content.wash.split('-')
        home_team = teams[0]
        away_team = teams[1]
        lanes_index = 2

        # dateFix = date.split('/')
        # if (dateFix.length > 0)
        #   day_zero = ''
        #   day_zero = '0' if dateFix[0].length == 1
        #   date = "2018-0#{dateFix[1]}-#{day_zero}#{dateFix[0]}"
        # end

        timeFix = time.split('-')
        if (timeFix.length > 0)
          time = timeFix[0]
        end
      else
        home_team = cells[home_team_index].content.wash
        away_team = cells[away_team_index].content.wash
      end

      next if (time == 'Tid')
      next if date == time

      lanes = cells[lanes_index].content.wash

      # division = 'DamdubbelDiv2'
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
