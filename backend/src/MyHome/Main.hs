{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module MyHome.Main(main, testApp) where

import qualified Web.Spock as Spock
import qualified Web.Spock.Config as Spock
import Data.Aeson hiding (json,Result)
import Data.Pool
import GHC.Generics
import Control.Monad.IO.Class
import Control.Monad.Reader
import Control.Monad.Except
import Database.Persist.MySQL
import Database.Persist
import Database.Persist.TH
import Control.Monad.Logger
import Data.Text.Lazy(Text)
import qualified Data.Text as Strict
import Network.Wai.Middleware.RequestLogger
import Network.Wai(Middleware)
import MyHome.Schema
import MyHome.Form
import MyHome.Logic
import MyHome.Type
import MyHome.Service
import Control.Monad
import Control.Monad.Catch
import Control.Monad.IO.Unlift
import Data.Typeable
import Database.MySQL.Base(ERRException)

data MySession = EmptySession
data MyAppState = DummyAppState 


runDB :: ReaderT SqlBackend IO a -> Spock.SpockAction SqlBackend MySession MyAppState a
runDB = Spock.runQuery . runSqlConn

runLogic :: forall a. ReaderT SqlBackend IO a -> Spock.SpockAction SqlBackend MySession MyAppState (Result a)
runLogic action = Spock.runQuery (runSqlConn actionCatch)
    where
        actionCatch :: ReaderT SqlBackend IO (Result a)
        actionCatch = (Ok <$> action)
            `catch` (\e -> pure $ Err e)
            `catch` (\(e :: ERRException) -> pure $ Err (AppException EDatabaseERR ""))

        

scottyMain :: Spock.SpockM SqlBackend MySession MyAppState ()
scottyMain = do
    Spock.get "/" $ do
        Spock.json $ Hello "Hello World!"
    Spock.get "/dbtest/select" $ do
        msg <- runDB $ map entityVal <$> selectList [] []
        Spock.json $ (msg :: [Hello])
    Spock.post "/dbtest/insert" $ do
        HelloForm{message = msg} <- Spock.jsonBody'
        runDB $ void $ insert (Hello msg)
    Spock.post "/auth/signin" $ do
        form <- Spock.jsonBody'
        result <- runLogic $ signin form 
        Spock.json $ fmap authUsername result
    Spock.post "/auth/signup" $ do
        form <- Spock.jsonBody'
        salt <- liftIO genSalt
        let mauth = runExcept (hashPassword form salt)
        case mauth of
            Left err -> Spock.json $ show err
            Right auth -> do
                runDB $ insert auth
                Spock.json $ "Succeeded, " <> authUsername auth 

main :: IO ()
main = do
    let info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"
    pool <- runStdoutLoggingT $ createMySQLPool info 20
    runStdoutLoggingT $ withMySQLConn info (runSqlConn (runMigration migrateAll))
    spockCfg <- Spock.defaultSpockCfg EmptySession (Spock.PCPool pool) DummyAppState
    Spock.runSpock 3000 $ fmap (logStdout.) $ Spock.spock spockCfg scottyMain

testApp :: IO Middleware
testApp = do
    let info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"
    pool <- runStdoutLoggingT $ createMySQLPool info 20
    runStdoutLoggingT $ withMySQLConn info (runSqlConn (runMigration migrateAll))
    spockCfg <- Spock.defaultSpockCfg EmptySession (Spock.PCPool pool) DummyAppState
    Spock.spock spockCfg scottyMain

