{-# OPTIONS -Wall #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Monoid ((<>))
import Network.Njusko.Lib
import Network.Njusko.Options
import Options.Applicative

firstPage :: Integer
firstPage = 0

main :: IO ()
main = execParser opts >>= entrypoint
  where
    opts =
      info
        (helper <*> versionOpt <*> njuskoArgs)
        (fullDesc <>
         progDesc "Scrapes new apartments from Njuskalo given a search link." <>
         header "HNjusko - Njuskalo scraper in Haskell")
