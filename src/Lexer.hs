module Lexer where

import Data.Char (isAlpha, isSpace)

data Token
  = Union
  | Equal
  | Empty
  | Comma
  | Colon
  | LParen
  | RParen
  | LBrace
  | RBrace
  | Symbol Char
  deriving (Show)

-- Como tratar erros?

lexer :: String -> [Token]
lexer [] = []
lexer ('|' : cs) = Union : lexer cs
lexer ('=' : cs) = Equal : lexer cs
lexer ('&' : cs) = Empty : lexer cs
lexer (',' : cs) = Comma : lexer cs
lexer (':' : cs) = Colon : lexer cs
lexer ('(' : cs) = LParen : lexer cs
lexer (')' : cs) = RParen : lexer cs
lexer ('{' : cs) = LBrace : lexer cs
lexer ('}' : cs) = RBrace : lexer cs
lexer (c : cs)
  | isSpace c = lexer cs
  | isAlpha c = Symbol c : lexer cs
