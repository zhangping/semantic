module Parsing.Spec (spec) where

import Data.AST
import Data.Blob
import Data.ByteString.Char8 (pack)
import Data.Duration
import Data.Language
import Data.Maybe
import Parsing.TreeSitter
import Source.Source
import SpecHelpers
import TreeSitter.JSON (Grammar, tree_sitter_json)

spec :: Spec
spec = do
  describe "parseToAST" $ do
    let source = toJSONSource [1 :: Int .. 10000]
    let largeBlob = sourceBlob "large.json" JSON source

    it "returns a result when the timeout does not expire" $ do
      let timeout = fromMicroseconds 0 -- Zero microseconds indicates no timeout
      let parseTask = parseToAST timeout tree_sitter_json largeBlob :: TaskC (Maybe (AST [] Grammar))
      result <- runTaskOrDie parseTask
      (isJust result) `shouldBe` True

    it "returns nothing when the timeout expires" $ do
      let timeout = fromMicroseconds 1000
      let parseTask = parseToAST timeout tree_sitter_json largeBlob :: TaskC (Maybe (AST [] Grammar))
      result <- runTaskOrDie parseTask
      (isNothing result) `shouldBe` True

toJSONSource :: Show a => a -> Source
toJSONSource = fromUTF8 . pack . show
