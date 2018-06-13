{-# LANGUAGE OverloadedStrings #-}

module Network.Njusko.Lib where

import Control.Concurrent (threadDelay)
import Control.Exception (catch)
import Control.Monad (forM, forM_)
import Data.List (nub, reverse)
import Data.Maybe (catMaybes)
import Data.Monoid ((<>))
import qualified Data.Text.Lazy as T
import qualified Data.Text.Lazy.IO as TIO
import Data.Traversable (for)
import Database.SQLite.Simple
import qualified Network.Curl as Curl
import Network.Mail.SMTP (plainTextPart, sendMail, simpleMail)
import Network.Mail.SMTP.Types
import Text.HTML.Scalpel
import Text.StringTemplate
import Text.StringTemplate.GenericStandard

import Network.Njusko.Options
import Network.Njusko.Types

-- splitURL :: T.Text -> [T.Text]
-- splitURL = T.splitOn "/"
-- getURLParams :: [T.Text] -> T.Text
-- getURLParams = last
baseURL :: T.Text
baseURL = "http://www.njuskalo.hr"

template :: StringTemplate String
template =
  newSTMP $
  unlines
    [ "Hi there,\n\n"
    , "These are the new ads I've found matching your criteria:\n\n"
    , "$urls;separator='\n'$"
    ]

body :: [T.Text] -> T.Text
body xs = T.pack $ toString $ setAttribute "urls" xs template

notify :: T.Text -> [String] -> IO ()
notify rt es = do
  sendMail "localhost" (constructMessage rt)
  where
    from = Address {addressName = Nothing, addressEmail = "root@localhost"}
    to =
      [ Address {addressName = Nothing, addressEmail = T.toStrict $ T.pack e}
      | e <- es
      ]
    subject = "Njusko - New njuskalo.hr ads found!"
    cc = []
    bcc = []
    bodyPart rt = [plainTextPart rt]
    constructMessage rt = simpleMail from to cc bcc subject (bodyPart rt)

entrypoint :: NjuskoArgs -> IO ()
entrypoint args = do
  conn <- open "db.sqlite"
  execute_
    conn
    "CREATE TABLE IF NOT EXISTS links (id INTEGER PRIMARY KEY, url TEXT UNIQUE)"
  existingUrls <-
    map fromOnly <$> query_ conn "SELECT url FROM links" :: IO [T.Text]
  res <- njuskoScrape args
  let absRes = filter (\x -> notElem x existingUrls) $ appendBase res
  processResult absRes conn args
  where
    appendBase xs = map (\x -> T.append baseURL (T.pack x)) xs

processResult :: [T.Text] -> Connection -> NjuskoArgs -> IO ()
processResult [] _ _ = return ()
processResult xs c args = do
  case (debug args) of
    True -> putStrLn $ T.unpack (body xs)
    False -> do
      insertMultipleEntries c xs
      notify (body xs) (notificationEmails args)

insertMultipleEntries :: Connection -> [T.Text] -> IO ()
insertMultipleEntries c es =
  forM_ es $ \e -> do
    insertEntry c e `catch` \err
        -- It shouldn't actually come to this unless used
        -- in some other context then in entrypoint
     -> do
      let e = show (err :: SQLError)
      putStrLn "URL already in database. Ignoring."

insertEntry :: Connection -> T.Text -> IO ()
insertEntry c e =
  execute c "INSERT INTO links (url) VALUES (?)" (Only ((T.unpack e) :: String))

unique :: Eq a => [a] -> [a]
unique = reverse . nub . reverse

njuskoScrape :: NjuskoArgs -> IO [URL]
njuskoScrape args = do
  f <- TIO.readFile $ urlFilePath args
  let urls = filter (/= "") $ T.lines f
  filterInvalid $ uniqueAndFlatten $ for urls $ \u -> scrapePage (T.unpack u)
  where
    filterInvalid xs =
      fmap
        (filter
           (\x -> T.isPrefixOf (getValidPrefix $ scraperType args) (T.pack x)))
        xs
    uniqueAndFlatten xs = fmap (unique . flatten) xs

getValidPrefix :: ScraperType -> T.Text
getValidPrefix t =
  case t of
    APT -> "/nekretnine/"
    CAR -> "/auti/"

flatten :: [[a]] -> [a]
flatten [] = []
flatten [[]] = []
flatten (x:xs) = x ++ flatten xs

scrapePage :: URL -> IO [URL]
scrapePage u = fmap (flatten . catMaybes) $ mapM allLinks $ map nextPage pages
  where
    nextPage p = u ++ "?page=" ++ (show p)
              -- FIX : This is stupid we should page through all the pages
    pages = [1 .. 20]

fakeAgent :: String
fakeAgent =
  "Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"

allLinks :: String -> IO (Maybe [URL])
allLinks l = do
  threadDelay 20000000
  scrapeURLWithOpts
    [Curl.CurlUserAgent fakeAgent, Curl.CurlFollowLocation True]
    l
    getLinks
  where
    getLinks :: Scraper String [URL]
    getLinks =
      chroots
        (li @:
         [ hasClass "EntityList-item"
         , notP $ hasClass "EntityList-item--Latest"
         , notP $ hasClass "EntityList-item--SuperVau"
         , notP $ hasClass "EntityList-item--FeaturedStore"
         ])
        link
    link :: Scraper String URL
    link = do
      url <- attr href $ a
      return $ url
    href = "href"
    li = "li"
    a = "a"
