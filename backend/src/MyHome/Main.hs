{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module MyHome.Main where

import qualified Web.Scotty as Scotty
import Data.Aeson hiding (json)
import Data.Pool
import GHC.Generics
import Control.Monad.IO.Class
import Database.Persist.MySQL
import Database.Persist
import Database.Persist.TH
import Control.Monad.Logger
import Data.Text.Lazy(Text)


share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Hello json
    message String
|]

scottyMain :: Pool SqlBackend -> Scotty.ScottyM ()
scottyMain backendPool = do
   Scotty.get "/" $ do
       Scotty.json $ Hello "Hello World!"
   Scotty.get "/dbtest" $ do
       msg <- liftIO $ flip runSqlPool backendPool $ do
           map entityVal <$> selectList [] []
       Scotty.json $ (msg :: [Hello])

main :: IO ()
main = do
    let info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"
    pool <- runStdoutLoggingT $ createMySQLPool info 20
    runStdoutLoggingT $ withMySQLConn info (runSqlConn (runMigration migrateAll))
    Scotty.scotty 3000 $ scottyMain pool
       
