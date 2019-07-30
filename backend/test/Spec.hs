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

spec :: Spec
spec = before_ initDB $ do 
    describe "signin" $
        it "raises ENoSuchUser for not registered username" $ do
            (runNoLoggingT $ withMySQLConn info $ \conn ->
                liftIO $ runSqlConn (signin LoginForm{ username = "testuser", password = "password"}) conn)
                `shouldThrow` anyENoSuchUser


            1 `shouldBe` 1
