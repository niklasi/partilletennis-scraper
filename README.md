# partilletennis-scraper
Scrape tennis series information from partilletennis.se

# Installation

If you don't have ruby installed, install it. You can download the latest
version from [ruby-lang.org](https://www.ruby-lang.org) or use [brew](https://brew.sh) or [rvm.io](https://rvm.io).

```
gem install bundler # if not installed
bundle install
```

# Usage
```
rake -T

rake foretagstennis:all      # Get both matches and teams
rake foretagstennis:matches  # Get all matches
rake foretagstennis:teams    # Get all teams
rake motionserier:all        # Get both matches and teams
rake motionserier:matches    # Get alll matches
rake motionserier:teams      # Get all teams
```
