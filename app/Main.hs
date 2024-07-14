module Main where

import Grammar
import Parser

t :: [String]
t =
  [ "ab",
    "aab",
    "aabb",
    "aacbb",
    "c",
    "a",
    "",
    "abc",
    "aabbcc",
    "aabc"
  ]

main :: IO ()
main = do
  gr <- readFile "example.gr"
  let g = parse gr
  print $ zip t (map (recognize g (start g)) t)
