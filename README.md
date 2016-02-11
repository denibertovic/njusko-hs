# Njusko

A simple scraper for Njuskalo ads. Scrapes the urls you give it and notifies you
via email when new entries are found.

This is a CLI app that is intended to be used as a cron job.



## Usage


    HNjusko - Njuskalo scraper in Haskell

    Usage: njusko (-u|--url-file PATH) (-t|--type TYPE) (-n|--notify EMAIL)
                         [--debug]
      Scrapes new apartments from Njuskalo given a search link.

    Available options:
      -h,--help                Show this help text
      -u,--url-file PATH       File that contains list of search urls on each line.
      -t,--type TYPE           Type of scraper to be used. Available types: APT, CAR
      -n,--notify EMAIL        The email to send notifications to.
      --debug                  Print out results to stdout and don't send emails

Create a urls.txt file with njuskalo search param in it. Be sure to remove the "page"
parameter though. The scraper will parse that file and search all pages for a given url.
It will store the new found ads into a sqlite databse and notify you if there are any
new ads.

## Issues

Report issues on the Issue tracker: https://github.com/denibertovic/njusko-hs/issues

## How to build

1. Install [stack](https://github.com/commercialhaskell/stack/releases)

2. Clone the repo (or fork it first and then clone):

    `git clone git@github.com:denibertovic/njusko-hs.git`

3. Build:

    `cd njusko-hs && make build`

