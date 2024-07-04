module Grammar where

newtype Terminal = Terminal Char deriving (Show)

newtype Variable = Variable Char deriving (Show)

data Production
  = Production
  { from :: Variable,
    string :: [Terminal],
    to :: Variable
  }
  deriving (Show)

data Grammar
  = Grammar
  { terminals :: [Terminal],
    variables :: [Variable],
    start :: Variable,
    productions :: [Production]
  }
  deriving (Show)
