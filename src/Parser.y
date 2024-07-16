{
module Parser where

import Grammar
import Lexer
import Control.Monad.Identity
}

%name parser 
%tokentype { Token }
%error { parseError }
%monad { Identity } { (>>=) } { return }

%token
      usym            { UpperSymbol $$ }
      lsym            { LowerSymbol $$ }
      ','             { Comma }
      ':'             { Colon }
      '('             { LParen }
      ')'             { RParen }
      '{'             { LBrace }
      '}'             { RBrace }
      epsilon         { Empty }

%%

grammar   :: { Grammar }
          : '(' terms ',' vars ',' usym ',' prods ')' { Grammar $2 $4 (Variable $6) $8 }

terms     :: { [Terminal] } 
          : '{' terms_ '}'                            { $2 }

terms_    :: { [Terminal] }
          : lsym                                      { [Terminal $1] }
          | lsym ',' terms_                           { Terminal $1 : $3 }

vars      :: { [Variable] }
          : '{' vars_ '}'                             { $2 }

vars_     :: { [Variable] }
          : usym                                      { [Variable $1] }
          | usym ',' vars_                            { Variable $1 : $3 }

prods     :: { [Production] }
          : '{' prods_ '}'                            { $2 }

prods_    :: { [Production] }
          : prod                                      { [$1] }
          | prod ',' prods_                           { $1 : $3 }

prod      :: { Production }
          : usym ':' lsyms maybeusym                  { Production (Variable $1) $3 $4 }

lsyms     :: { [Terminal] }
          : {- empty -}                               { [] }
          | epsilon                                   { [] }
          | lsym lsyms                                { Terminal $1 : $2 }

maybeusym :: { Maybe Variable }
          : {- empty -}                               { Nothing }
          | usym                                      { Just $ Variable $1 }
          
{
parseError :: [Token] -> Identity a
parseError tk = error $ "grammar parsing error" ++ show tk

parse :: String -> Grammar
parse s = runIdentity (parser $ lexer s)
}
