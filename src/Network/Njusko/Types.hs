{-# LANGUAGE OverloadedStrings #-}

module Network.Njusko.Types where

import Control.Applicative
import qualified Data.Text as T
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToField
import Database.SQLite.Simple.ToRow

data LinkField =
  LinkField Int
            T.Text
  deriving (Show)

instance FromRow LinkField where
  fromRow = LinkField <$> field <*> field

instance ToRow LinkField where
  toRow (LinkField id_ url) = toRow (id_, url)
