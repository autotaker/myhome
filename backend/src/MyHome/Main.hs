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
import Network.Wai.Middleware.RequestLogger
import MyHome.Schema
import MyHome.Form
import Control.Monad

data MySession = EmptySession
data MyAppState = DummyAppState 

scottyMain :: Spock.SpockM SqlBackend MySession MyAppState ()
scottyMain = do
    Spock.get "/" $ do
        Spock.json $ Hello "Hello World!"
    Spock.get "/dbtest/select" $ do
        msg <- Spock.runQuery $ \conn -> flip runSqlConn conn $
            map entityVal <$> selectList [] []
        Spock.json $ (msg :: [Hello])
    Spock.post "/dbtest/insert" $ do
        HelloForm{message = msg} <- Spock.jsonBody'
        Spock.runQuery $ \conn -> flip runSqlConn conn $
            void $ insert (Hello msg)


main :: IO ()
main = do
    let info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"
    pool <- runStdoutLoggingT $ createMySQLPool info 20
    runStdoutLoggingT $ withMySQLConn info (runSqlConn (runMigration migrateAll))
    spockCfg <- Spock.defaultSpockCfg EmptySession (Spock.PCPool pool) DummyAppState
    Spock.runSpock 3000 $ fmap (logStdout.) $ Spock.spock spockCfg scottyMain
       
