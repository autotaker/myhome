{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module MyHome.Main where

import Web.Scotty
import Data.Aeson hiding (json)
import GHC.Generics

data Hello = 
    Hello { message :: String }
    deriving(Generic)

instance ToJSON Hello

main :: IO ()
main = scotty 3000 $ do
       get "/" $ do
           json $ Hello { message = "Hello World!" }
