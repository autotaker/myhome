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

spec :: Spec
spec = before_ initDB $ do 
    describe "signin" $ do
        it "raises ENoSuchUser for not registered username" $ 
            (runNoLoggingT $ withMySQLConn info $ \conn ->
                liftIO $ runSqlConn (signin LoginForm{ username = "testuser", password = "password"}) conn)
                `shouldThrow` anyENoSuchUser
        it "one can signin after signup" $ 
            (runStderrLoggingT $ withMySQLConn info $ \conn ->
                liftIO $ flip runSqlConn conn $ do
                    let form = LoginForm{ username = "testuser", password = "password" }
                    _ <- signup form
                    auth <- signin form
                    pure $ authUsername auth) `shouldReturn` "testuser"
        it "cannot signup for existing username" $
            (runStderrLoggingT $ withMySQLConn info $ \conn ->
                liftIO $ flip runSqlConn conn $ do
                    let form = LoginForm{ username = "testuser", password = "password" }
                    _ <- signup form
                    _ <- signup form
                    pure ()) `shouldThrow` anyEUsernameExists                    
