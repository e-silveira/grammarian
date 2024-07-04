module Main where

import Parser

main :: IO ()
main = do
  gr <- readFile "example.gr"
  print $ parse gr

