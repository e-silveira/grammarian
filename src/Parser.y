{
module Parser where

import Grammar
import Lexer
}

%name parser 
%tokentype { Token }
%error { parseError }
%monad { Either String } { (>>=) } { return }

%token
      usym            { UpperSymbol $$ }
      lsym            { LowerSymbol $$ }
      '='             { Equal }
      ','             { Comma }
      ':'             { Colon }
      '('             { LParen }
      ')'             { RParen }
      '{'             { LBrace }
      '}'             { RBrace }

%%

grammar : usym '=' '(' terms ',' vars ',' usym ',' prods ')' { Grammar $4 $6 (Variable $8) $10 }

terms   : '{' terms_ '}'                                  { $2 }
terms_  : lsym                                            { [Terminal $1] }
        | terms_ ',' lsym                                 { Terminal $3 : $1 }

vars    : '{' vars_ '}'                                   { $2 }
vars_   : usym                                            { [Variable $1] }
        | vars_ ',' usym                                  { Variable $3 : $1 }

prods   : '{' prods_ '}'                                  { $2 }
prods_  : prod                                            { [$1] }
        | prods_ ',' prod                                 { $3 : $1 }

prod    : usym ':' lsyms maybeusym                        { Production (Variable $1) $3 $4 }

lsyms  : lsym                                             { [Terminal $1] }
        | lsyms lsym                                      { Terminal $2 : $1 }

maybeusym : {- empty -}                                   { Nothing }
          | usym                                          { Just $ Variable $1 }
          
{
parseError :: [Token] -> Either String a
parseError = Left . show 

parse :: String -> Either String Grammar
parse s = parser $ lexer s
}
