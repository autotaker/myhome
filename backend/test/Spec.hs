{-# LANGUAGE OverloadedStrings #-}
import Test.Hspec

import MyHome.Schema
import MyHome.Service
import MyHome.Form
import MyHome.Type
import Database.Persist.MySQL
import Database.Persist
import Control.Monad.Logger
import Control.Monad.Reader

info = mkMySQLConnectInfo "127.0.0.1" "myhome" "myhome" "myhome_test"

main :: IO ()
main = do
    runStdoutLoggingT $ withMySQLConn info (runSqlConn (runMigration migrateAll))
    hspec spec

initDB = do
    runNoLoggingT $ withMySQLConn info (runSqlConn deleteAll) 

anyENoSuchUser :: Selector AppException
anyENoSuchUser (AppException ENoSuchUser _) = True
anyENoSuchUser_ = False

anyEUsernameExists :: Selector AppException
anyEUsernameExists (AppException EUsernameExists _) = True
anyEUsernameExists _ = False

anyEInvalidPassword (AppException EInvalidPassword _) = True
anyEInvalidPassword _ = False

spec :: Spec
spec = before_ initDB $ do 
    describe "signin" $ do
        it "raises ENoSuchUser for not registered username" $ 
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                runSqlConn (signin LoginForm{ username = "testuser", password = "password"}) conn)
                `shouldThrow` anyENoSuchUser

    describe "signup" $ do
        it "doesn't accept non-ascii chars" $ do
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                flip runSqlConn conn $ do
                    let form = LoginForm{ username = "testuser", password = "あいうえお" }
                    _ <- signup form
                    pure ()) `shouldThrow` anyEInvalidPassword
        it "doesn't accept password longer than 72 characters" $ do
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                flip runSqlConn conn $ do
                    let longpass = "AAAAAAAA" <> "AAAAAAAA" <> "AAAAAAAA"
                                 <> "AAAAAAAA" <> "AAAAAAAA" <> "AAAAAAAA"
                                 <> "AAAAAAAA" <> "AAAAAAAA" <> "AAAAAAAA"
                    let form = LoginForm{ username = "testuser", password = longpass <> "A" }
                    _ <- signup form
                    pure ()) `shouldThrow` anyEInvalidPassword
        it "accepts passwords no longer than 72 characters" $ do
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                flip runSqlConn conn $ do
                    let longpass = "AAAAAAAA" <> "AAAAAAAA" <> "AAAAAAAA"
                                 <> "AAAAAAAA" <> "AAAAAAAA" <> "AAAAAAAA"
                                 <> "AAAAAAAA" <> "AAAAAAAA" <> "AAAAAAAA"
                    let form = LoginForm{ username = "testuser", password = longpass }
                    signup form
                    pure ()) `shouldReturn` ()
        it "cannot signup for existing username" $
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                flip runSqlConn conn $ do
                    let form = LoginForm{ username = "testuser", password = "password" }
                    _ <- signup form
                    _ <- signup form
                    pure ()) `shouldThrow` anyEUsernameExists                    

    describe "signin/signup" $ do
        it "one can signin after signup" $ 
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                flip runSqlConn conn $ do
                    let form = LoginForm{ username = "testuser", password = "password" }
                    _ <- signup form
                    auth <- signin form
                    pure $ authUsername auth) `shouldReturn` "testuser"

        it "raise an EInvalidPassword when user signins with invalid password" $ 
            (runStdoutLoggingT $ withMySQLConn info $ \conn ->
                flip runSqlConn conn $ do
                    let form = LoginForm{ username = "testuser", password = "password" }
                        form' = LoginForm{ username = "testuser", password = "wrong" }
                    _ <- signup form
                    signin form') `shouldThrow` anyEInvalidPassword
