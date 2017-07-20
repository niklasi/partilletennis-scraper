class String
  def wash
    self
      .gsub("\r\n", "")
      .gsub("&nbsp;", "")
      .gsub(/(\s|\u00A0)+/, ' ')
      .split(" ")
      .join(" ")
  end
end

def get_day(date)
  day = date.split(" ")[0]

  return day if day.length > 1

  return "0#{day}"
end

def get_month(date)
  return "01" if date.include?("jan")
  return "02" if date.include?("feb")
  return "03" if date.include?("mar")
  return "04" if date.include?("apr")
  return "05" if date.include?("maj")
  return "06" if date.include?("jun")
  return "07" if date.include?("jul")
  return "08" if date.include?("aug")
  return "09" if date.include?("sep")
  return "10" if date.include?("okt")
  return "11" if date.include?("nov")
  return "12" if date.include?("dec")
end


def get_season(date)
  return "fall" if date.include?("aug") || date.include?("sep") || date.include?("okt") || date.include?("nov") || date.include?("dec")
  "spring"
end

def decode_email(value)
  c = '!#$()*,-./0123456789:;?ABCDEFGHIJKLMNOPQRSTUVWXYZ[ ]^_abcdefghijklmnopqrstuvwxyz{|}~'
  e = ''
  f = value.length
  g = 0

  while g < f
    h = value[g]
    i = c.index(h)

    case i
    when -1
      e << h
    when 1
      e << 10.chr
    when 2
      e << 13.chr
    when 3
      g += 1
      e << value[g]
    else
      e << (i + 28).chr
    end
    g += 1
  end

  e
end
