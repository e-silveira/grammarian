module Grammar where

import Data.Maybe (mapMaybe)

newtype Terminal = Terminal Char deriving (Eq)

instance Show Terminal where
  show (Terminal c) = [c]

newtype Variable = Variable Char deriving (Eq)

instance Show Variable where
  show (Variable c) = [c]

data Production
  = Production
  { from :: Variable,
    string :: [Terminal],
    to :: Maybe Variable
  }

instance Show Production where
  show p =
    show (from p) ++
    " -> " ++
    show (string p) ++
    " " ++ maybe "" show (to p)

data Grammar
  = Grammar
  { terminals :: [Terminal],
    variables :: [Variable],
    start :: Variable,
    productions :: [Production]
  }

instance Show Grammar where
  show g = ("\nGrammar:\n\n" ++) . unlines $
    ($ g) <$>
    [ ("Terminals: "++)    . show.terminals,
      ("Variables: "++)    . show.variables,
      ("Start: "++)        . show.start,
      ("Productions:\n"++) . unlines.map show.productions
    ]

recognizeTerminals :: [Terminal] -> String -> (Bool, String)
recognizeTerminals [] s = (True, s)
recognizeTerminals _ [] = (False, [])
recognizeTerminals (Terminal t : ts) (c : cs)
  | t == c = recognizeTerminals ts cs
  | otherwise = (False, c : cs)

recognizeProduction :: Production -> String -> Maybe (Maybe Variable, String)
recognizeProduction p s
  | recognized = Just (to p, rest)
  | otherwise = Nothing
  where
    (recognized, rest) = recognizeTerminals (string p) s

recognize' :: Grammar -> Maybe Variable -> String -> Bool
recognize' _ Nothing _ = False
recognize' g (Just v) s = recognize g v s

recognize :: Grammar -> Variable -> String -> Bool
recognize g v s
  | (Nothing, "") `elem` rp = True
  | null rp = False
  | otherwise = any (uncurry (recognize' g)) rp
  where
    pp = filter (\p -> from p == v) (productions g)
    rp = mapMaybe (`recognizeProduction` s) pp
