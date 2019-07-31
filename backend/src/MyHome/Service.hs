{-# LANGUAGE OverloadedStrings #-}
module MyHome.Service where
import Control.Monad.IO.Class
import Control.Monad.Reader
import Control.Monad.Except
import Database.Persist.MySQL
import Database.Persist
import MyHome.Schema
import MyHome.Form
import MyHome.Logic
import MyHome.Type
import Control.Monad
import Control.Monad.Catch
import Data.Text(pack)

signin :: LoginForm -> ReaderT SqlBackend IO Auth
signin form = do
    mAuthEntity <- getBy (UniqueUsername $ username form)
    case mAuthEntity of
        Nothing -> throwM (AppException ENoSuchUser "")
        Just (Entity _ auth) | validatePassword form auth -> pure auth
        Just _ -> throwM (AppException EInvalidPassword "")

signup :: LoginForm -> ReaderT SqlBackend IO Auth
signup form = do
    salt <- liftIO genSalt
    let mauth = runExcept (hashPassword form salt)
    case mauth of
        Left err -> throwM (AppException EInvalidPassword ("invalid hash" <> pack (show err) ))
        Right auth -> do
            insert auth
            pure auth

        
