module Main where

import Grammar
import Parser
import System.IO
import System.Environment (getArgs)

read' :: IO String
read' = do
  putStr "> "
  hFlush stdout
  getLine

main :: IO ()
main = do
  filename <- getArgs
  gr <- readFile $ head filename
  print $ parse gr
  main' $ parse gr

main' :: Grammar -> IO ()
main' g = do
  input <- read'
  print $ recognize g (start g) input
  main' g
