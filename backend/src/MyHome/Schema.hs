{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module MyHome.Schema(
    migrateAll
  , Hello(..)
  , Auth(..)
  , Unique(UniqueUsername)
  , deleteAll)where

import Data.Aeson hiding (json)
import Data.Pool
import GHC.Generics
import Control.Monad.IO.Class
import Database.Persist.MySQL
import Database.Persist
import Database.Persist.TH
import Control.Monad.Reader
import qualified Data.Text.Lazy as Lazy
import qualified Data.Text as Strict
import Data.ByteString(ByteString)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Hello json
    message Lazy.Text

Auth
    username Strict.Text sqltype=varchar(255)
    password ByteString sqltype=char(60)
    Primary username
    UniqueUsername username
|]

deleteAll :: MonadIO m => ReaderT SqlBackend m ()
deleteAll = do
    deleteWhere ([] :: [Filter Hello])
    deleteWhere ([] :: [Filter Auth])
