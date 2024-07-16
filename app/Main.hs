module Main where

import Grammar
import Runner
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
  let g = parse gr
  print g
  main' g

main' :: Grammar -> IO ()
main' g = do
  input <- read'
  print $ run g input
  main' g
