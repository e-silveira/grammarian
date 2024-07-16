module Grammar where

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
  } deriving (Eq)

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
