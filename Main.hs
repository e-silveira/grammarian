module Main where

import Grammar
import Lexer

main = do
  gr <- readFile "example.gr"
  print $ lexer gr
