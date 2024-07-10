module Grammar where

newtype Terminal = Terminal Char deriving (Eq, Show)

newtype Variable = Variable Char deriving (Eq, Show)

data Production
  = Production
  { from :: Variable,
    string :: [Terminal],
    to :: Maybe Variable
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
