{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module MyHome.Main where

import qualified Web.Spock as Spock
import qualified Web.Spock.Config as Spock
import Data.Aeson hiding (json)
import Data.Pool
import GHC.Generics
import Control.Monad.IO.Class
import Database.Persist.MySQL
import Database.Persist
import Database.Persist.TH
import Control.Monad.Logger
import Data.Text.Lazy(Text)
import MyHome.Schema
import MyHome.Form
import Control.Monad

data MySession = EmptySession
data MyAppState = DummyAppState 

scottyMain :: Pool SqlBackend -> Spock.SpockM () MySession MyAppState ()
scottyMain backendPool = do
    Spock.get "/" $ do
        Spock.json $ Hello "Hello World!"
    Spock.get "/dbtest/select" $ do
        msg <- liftIO $ flip runSqlPool backendPool $ do
            map entityVal <$> selectList [] []
        Spock.json $ (msg :: [Hello])
    Spock.post "/dbtest/insert" $ do
        HelloForm{message = msg} <- Spock.jsonBody'
        liftIO $ flip runSqlPool backendPool $ do
            void $ insert (Hello msg)


main :: IO ()
main = do
    let info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"
    pool <- runStdoutLoggingT $ createMySQLPool info 20
    runStdoutLoggingT $ withMySQLConn info (runSqlConn (runMigration migrateAll))
    spockCfg <- Spock.defaultSpockCfg EmptySession Spock.PCNoDatabase DummyAppState
    Spock.runSpock 3000 $ (Spock.spock spockCfg (scottyMain pool))
       
