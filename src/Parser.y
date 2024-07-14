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

%%

grammar :: {Grammar}
        : '(' terms ',' vars ',' usym ',' prods ')' { Grammar $2 $4 (Variable $6) $8 }

terms   :: {[Terminal]} 
        : '{' terms_ '}'                                  { $2 }

terms_  :: {[Terminal]}
        : lsym                  { [Terminal $1] }
        | terms_ ',' lsym       { Terminal $3 : $1 }

vars    :: {[Variable]}
        : '{' vars_ '}'                                   { $2 }

vars_   :: {[Variable]}
        : usym                  { [Variable $1] }
        | vars_ ',' usym        { Variable $3 : $1 }

prods   :: {[Production]}
        : '{' prods_ '}'                                  { $2 }

prods_  :: {[Production]}
        : prod                                            { [$1] }
        | prods_ ',' prod                                 { $3 : $1 }

prod    :: {Production}
        : usym ':' lsyms maybeusym                        { Production (Variable $1) $3 $4 }

lsyms   :: {[Terminal]}
        : {- empty -}                                   { [] }
        | lsyms lsym                                      { Terminal $2 : $1 }

maybeusym :: {Maybe Variable}
          : {- empty -}                                   { Nothing }
          | usym                                          { Just $ Variable $1 }
          
{
parseError :: [Token] -> Identity a
parseError tk = error $ "grammar parsing error" ++ show tk

parse :: String -> Grammar
parse s = runIdentity (parser $ lexer s)
}
