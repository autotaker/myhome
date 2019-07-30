{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE OverloadedStrings #-}
module MyHome.Type where
import Data.Aeson hiding(Result)
import Control.Exception
import Data.Text
import Data.Typeable


data Result a = Ok a | Err AppException
    deriving(Functor)

data AppException = AppException !ErrorCode !Text
  deriving(Show, Typeable)

data ErrorCode =
    ENoSuchUser
  | EInvalidPassword
  | EDatabaseERR
  | EOther
  deriving(Show, Typeable)

instance ToJSON ErrorCode where
    toEncoding ENoSuchUser = toEncoding ("ENoSuchUser" :: Text)
    toEncoding EInvalidPassword = toEncoding ("EInvalidPassword" :: Text)
    toEncoding EDatabaseERR = toEncoding ("EDatabaseERR" :: Text)
    toEncoding EOther = toEncoding ("EOther" :: Text)
    toJSON ENoSuchUser = toJSON ("ENoSuchUser" :: Text)
    toJSON EInvalidPassword = toJSON ("EInvalidPassword" :: Text)
    toJSON EDatabaseERR = toJSON ("EDatabaseERR" :: Text)
    toJSON EOther = toJSON ("EOther" :: Text)

instance ToJSON a => ToJSON (Result a) where
    toEncoding (Err (AppException code reason)) = 
        pairs ("error" .= code <> "reason" .= reason)
    toEncoding (Ok a) = toEncoding a
    toJSON (Err (AppException code reason)) =
        object ["error" .= code, "reason" .= reason]
    toJSON (Ok a) = toJSON a

instance Exception AppException
