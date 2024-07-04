module Grammar where

newtype Terminal = Terminal String deriving (Show)

newtype Variable = Variable String deriving (Show)

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
