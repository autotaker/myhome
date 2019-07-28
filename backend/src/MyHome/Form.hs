{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module MyHome.Form(HelloForm(..)) where

import Data.Aeson
import Data.Text.Lazy(Text) 
import GHC.Generics

data HelloForm = HelloForm { message :: Text }
    deriving(Show, Eq, Ord, Generic)

instance ToJSON HelloForm where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON HelloForm

data LoginForm = LoginForm { username :: Text, password :: Text }
    deriving(Show, Eq, Ord, Generic)

instance ToJSON LoginForm where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON LoginForm

