{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
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
import Control.Monad.Logger
import Data.Text(pack)
import Database.MySQL.Base(ERRException)
import Data.Maybe

signin :: LoginForm -> ReaderT SqlBackend (LoggingT IO) Auth
signin form = do
    logDebugN $ "signin form=" <> pack (show form)
    mAuthEntity <- getBy (UniqueUsername $ username form)
    case mAuthEntity of
        Nothing -> throwM (AppException ENoSuchUser "")
        Just (Entity _ auth) | validatePassword form auth -> pure auth
        Just _ -> throwM (AppException EInvalidPassword "")

signup :: LoginForm -> ReaderT SqlBackend (LoggingT IO) Auth
signup form = do
    salt <- liftIO genSalt
    let mauth = runExcept (hashPassword form salt)
    case mauth of
        Left err -> throwM (AppException EInvalidPassword ("invalid hash" <> pack (show err) ))
        Right auth -> do
            mAuth <- getBy (UniqueUsername $ username form)
            when (isJust mAuth) $ throwM $ AppException EUsernameExists ""
            insert auth `catch` (\(e :: ERRException) -> do
                logWarnN $ "failed to signup: " <> pack (show e)
                throwM (AppException EDatabaseERR ""))
            pure auth
