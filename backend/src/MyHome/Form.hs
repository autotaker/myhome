{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module MyHome.Form(HelloForm(..), LoginForm(..)) where

import Data.Aeson
import qualified Data.Text.Lazy as Lazy
import qualified Data.Text as Strict
import GHC.Generics

data HelloForm = HelloForm { message :: !Lazy.Text }
    deriving(Show, Eq, Ord, Generic)

instance ToJSON HelloForm where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON HelloForm

data LoginForm = LoginForm { username :: !Strict.Text, password :: !Strict.Text }
    deriving(Eq, Ord, Generic)

instance Show LoginForm where
    show LoginForm{username = username} =
        "LoginForm{username=" ++ show username ++ ",password=**secured**}"

instance ToJSON LoginForm where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON LoginForm

