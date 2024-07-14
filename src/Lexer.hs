module Lexer where

import Data.Char (isAlpha, isSpace, isLower, isUpper)

data Token
  = Empty
  | Comma
  | Colon
  | LParen
  | RParen
  | LBrace
  | RBrace
  | LowerSymbol Char
  | UpperSymbol Char
  deriving (Show)

lexer :: String -> [Token]
lexer [] = []
lexer ('&' : cs) = Empty : lexer cs
lexer (',' : cs) = Comma : lexer cs
lexer (':' : cs) = Colon : lexer cs
lexer ('(' : cs) = LParen : lexer cs
lexer (')' : cs) = RParen : lexer cs
lexer ('{' : cs) = LBrace : lexer cs
lexer ('}' : cs) = RBrace : lexer cs
lexer (c : cs)
  | isSpace c = lexer cs
  | isAlpha c && isLower c = LowerSymbol c : lexer cs
  | isAlpha c && isUpper c = UpperSymbol c : lexer cs
lexer _ = error "Unhandled character."
