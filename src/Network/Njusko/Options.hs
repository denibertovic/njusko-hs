{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings #-}

module Network.Njusko.Options where

import Data.Data (Data)
import Data.Monoid ((<>))
import Data.Typeable (Typeable)
import Data.Version (showVersion)
import Options.Applicative
import Paths_njusko

data ScraperType
  = APT
  | CAR
  deriving (Eq, Show, Read, Data, Typeable)

data NjuskoArgs = NjuskoArgs
  { urlFilePath :: String
  , scraperType :: ScraperType
  , notificationEmails :: [String]
  , debug :: Bool
  }

versionOpt =
  infoOption
    (showVersion version)
    (long "version" <> short 'v' <> help "Show version.")

njuskoArgs :: Parser NjuskoArgs
njuskoArgs =
  NjuskoArgs <$>
  strOption
    (long "url-file" <> short 'u' <> metavar "PATH" <>
     help "File that contains list of search urls on each line.") <*>
  option
    auto
    (long "type" <> short 't' <> metavar "TYPE" <>
     help "Type of scraper to be used. Available types: APT, CAR") <*>
  some
    (strOption
       (long "notify" <> short 'n' <> metavar "EMAIL" <>
        help "The email to send notifications to.")) <*>
  switch
    (long "debug" <> help "Print out results to stdout and don't send emails")
