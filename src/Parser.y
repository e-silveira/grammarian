{
module Parser where

import Grammar
import Lexer
}

%name parser 
%tokentype { Token }
%error { parseError }

%token
      sym             { Symbol $$ }
      '='             { Equal }
      ','             { Comma }
      ':'             { Colon }
      '('             { LParen }
      ')'             { RParen }
      '{'             { LBrace }
      '}'             { RBrace }

%%

grammar : sym '=' '(' terms ',' vars ',' sym ',' prods ')' { Grammar $4 $6 (Variable $8) $10 }

terms   : '{' terms_ '}'                                   { $2 }
terms_  : sym                                              { [Terminal $1] }
        | terms_ ',' sym                                   { Terminal $3 : $1 }

vars    : '{' vars_ '}'                                    { $2 }
vars_   : sym                                              { [Variable $1] }
        | vars_ ',' sym                                    { Variable $3 : $1 }

prods   : '{' prods_ '}'                                   { $2 }
prods_  : prod                                             { [$1] }
        | prods_ ',' prod                                  { $3 : $1 }

prod    : sym ':' sym sym                                  { Production (Variable $1) [Terminal $3] (Variable $4) }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"

parse :: String -> Grammar
parse s = parser $ lexer s
}
