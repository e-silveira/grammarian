module Main where

import Parser
import Lexer

main :: IO ()
main = do
  gr <- readFile "example.gr"
  print $ parse gr
  print $ Union
  print $ parser $ lexer gr

