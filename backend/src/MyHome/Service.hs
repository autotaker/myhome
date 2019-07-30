{-# LANGUAGE OverloadedStrings #-}
module MyHome.Service where
import Control.Monad.IO.Class
import Control.Monad.Reader
import Database.Persist.MySQL
import Database.Persist
import MyHome.Schema
import MyHome.Form
import MyHome.Logic
import MyHome.Type
import Control.Monad
import Control.Monad.Catch

signin :: LoginForm -> ReaderT SqlBackend IO Auth
signin form = do
    mAuthEntity <- getBy (UniqueUsername $ username form)
    case mAuthEntity of
        Nothing -> throwM (AppException ENoSuchUser "")
        Just (Entity _ auth) | validatePassword form auth -> pure auth
        Just _ -> throwM (AppException EInvalidPassword "")

