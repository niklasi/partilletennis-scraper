require "json"
require "nokogiri"
require "open-uri"
require "cgi"
require "./helpers"

module ExcerciseSeries
  def self.load (series)
    docs = Hash.new
    page = series
    page = series[0..8] if series.start_with? "Damdubbel"
    docs[series] = Nokogiri::HTML(open("https://idrottonline.se/ForeningenPartilleTennis-Tennis/Motionsserier/#{page}/"))

    teams = Array.new
    matches = Array.new
    docs.each do |series, doc|
      createTeam(series, doc) do |team|
        teams << team
      end
      createMatches(series, doc) do |match|
        matches << match
      end
    end

    return {:teams => teams, :matches => matches}
  end

  def self.createTeam (series, doc)
    if series == 'DamdubbelDiv2'
      rows = doc.css('.PageBodyDiv table:nth(3) tbody tr')
    else
      rows = doc.css('.PageBodyDiv table:first tbody tr')
    end
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

      yield ({
        :team_name => cells[1],
        :division => series,
        :team_ranking => cells[0].to_i.to_s,
        :contact => '',
        :phone => cells[cells.length - 1],
        :email => cells[2]
      })
    end
  end

  def self.createMatches (series, doc)
    if series == 'DamdubbelDiv2'
      rows = doc.css('.PageBodyDiv table:nth(4) tbody tr')
    else
      rows = doc.css('.PageBodyDiv table:nth(2) tbody tr')
    end
    if rows.length == 0 and series == 'Mixeddubbel'
      rows = doc.css('.PageBodyDiv table:nth-child(1) tbody tr')
    end
    # rows = doc.css('.PageBodyDiv div div table tbody tr')
    rows.each do |row|
      cells = row.css('td')

      next if cells.length < 3

      date = cells[0].content.wash
      time = cells[1].content.wash
      home_team_index = 3
      away_team_index = 4
      lanes_index = 2
      home_team = cells[home_team_index].content.wash
      away_team = cells[away_team_index].content.wash

      next if (time == 'Tid')
      next if date == time

      lanes = cells[lanes_index].content.wash

      # series = 'DamdubbelDiv2'
      yield ({
        home_team: home_team,
        away_team: away_team,
        date: date,
        time: time,
        lanes: lanes,
        division: series
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
