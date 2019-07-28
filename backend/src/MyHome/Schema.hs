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
  , Hello(..))where

import Data.Aeson hiding (json)
import Data.Pool
import GHC.Generics
import Control.Monad.IO.Class
import Database.Persist.MySQL
import Database.Persist
import Database.Persist.TH
import Data.Text.Lazy(Text)
import Data.ByteString(ByteString)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Hello json
    message Text

Auth
    Id
    username Text sqltype=varchar(255)
    password ByteString sqltype=char(60)
|]
