module MyHome.Logic where

import Crypto.BCrypt as BCrypt
import qualified Data.ByteString as B
import qualified MyHome.Form as F
import qualified MyHome.Schema as S
import Data.Text.Encoding(encodeUtf8)
import Control.Monad.Except
import qualified Data.Text as T
import Data.Char
import Data.Maybe

data AuthError = 
    InvalidSaltError 
    | InvalidCharacterError
    | TooLongPasswordError
    deriving(Show)

newtype Salt = Salt B.ByteString

hashPassword :: F.LoginForm -> Salt -> Except AuthError S.Auth
hashPassword loginForm (Salt salt) = do
    let fPasswd = F.password loginForm
    unless (T.all isAscii fPasswd) $ throwError InvalidCharacterError 
    unless (T.length fPasswd <= 72) $ throwError TooLongPasswordError
    let bPasswd = encodeUtf8 fPasswd
    hPasswd <- maybe (throwError InvalidSaltError) pure $ BCrypt.hashPassword bPasswd salt
    pure $ S.Auth{
        S.authUsername = F.username loginForm
      , S.authPassword = hPasswd
      }

genSalt :: IO Salt
genSalt = Salt . fromJust <$> BCrypt.genSaltUsingPolicy fastBcryptHashingPolicy

validatePassword :: F.LoginForm -> S.Auth -> Bool
validatePassword loginForm auth = BCrypt.validatePassword hashed raw
    where
        hashed = S.authPassword auth
        raw = encodeUtf8 $ F.password loginForm

