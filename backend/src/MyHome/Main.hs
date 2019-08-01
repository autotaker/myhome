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
module MyHome.Main(main) where

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
import Data.Text.Lazy(Text, fromStrict)
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

data MySession = 
    Guest | Authorized !Strict.Text
data MyAppState = 
    AppState {
      appLogger :: Loc -> LogSource -> LogLevel -> LogStr -> IO ()
    }


runDB :: ReaderT SqlBackend IO a -> Spock.SpockAction SqlBackend MySession MyAppState a
runDB = Spock.runQuery . runSqlConn

runLogic :: forall a. ReaderT SqlBackend (LoggingT IO) a -> Spock.SpockAction SqlBackend MySession MyAppState a
runLogic action = do
    logger <- appLogger <$> Spock.getState 
    Spock.runQuery (\conn -> runLoggingT (runReaderT action conn) logger)

scottyMain :: Spock.SpockM SqlBackend MySession MyAppState ()
scottyMain = do
    Spock.get "/" $ do
        session <- Spock.readSession
        let user = case session of 
                  Guest -> "Guest"
                  Authorized u -> u
        Spock.json $ Hello $ fromStrict $ "Hello World! " <> user
    Spock.get "/dbtest/select" $ do
        msg <- runDB $ map entityVal <$> selectList [] []
        Spock.json $ (msg :: [Hello])
    Spock.post "/dbtest/insert" $ do
        HelloForm{message = msg} <- Spock.jsonBody'
        runDB $ void $ insert (Hello msg)
    Spock.post "/auth/signin" $ do
        form <- Spock.jsonBody'
        auth <- runLogic $ signin form 
        Spock.sessionRegenerateId
        Spock.modifySession (const (Authorized (authUsername auth)))
        Spock.json () 
    Spock.post "/auth/signup" $ do
        form <- Spock.jsonBody'
        auth <- runLogic $ signup form
        pure ()
    Spock.post "/auth/signout" $ do
        Spock.writeSession Guest
        Spock.json ()

main :: IO ()
main = do
    let info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"
    logger <- runStdoutLoggingT $ askLoggerIO
    pool <- runLoggingT (createMySQLPool info 20) logger
    runLoggingT (withMySQLConn info (runSqlConn (runMigration migrateAll))) logger
    spockCfg <- Spock.defaultSpockCfg Guest (Spock.PCPool pool) (AppState logger)
    Spock.runSpock 3000 $ fmap (logStdout.) $ Spock.spock spockCfg scottyMain


