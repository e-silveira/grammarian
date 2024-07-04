{
module Main where

import Grammar
import Lexer
}

%name grammarian 
%tokentype { Token }
%error { parseError }

%token
      sym             { Symbol $$ }
      '|'             { Union }
      '='             { Attr }
      '&'             { Empty }
      '('             { LParen }
      ')'             { RParen }
      '{'             { LBrace }
      '}'             { RBrace }
      ','             { Comma }
      ':'             { Colon }

%%

G : sym '=' '(' T ',' V ',' S ',' P ')' { Grammar $4 $6 $8 $10 }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"
}
