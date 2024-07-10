{
module Parser where

import Grammar
import Lexer
import PMonad
}

%name parser 
%tokentype { Token }
%error { parseError }
%monad { PMonad Context } { (>>=) } { return }

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

grammar :: {Grammar}
        : usym '=' '(' terms ',' vars ',' usym ',' prods ')' { Grammar $4 $6 (Variable $8) $10 }

terms   :: {[Terminal]} 
        : '{' terms_ '}'                                  { $2 }
terms_  :: {[Terminal]}
        : lsym                  {% do
                                    assertContext (not . elem (Left $ Terminal $1)) "Duplicate terminal on definition"
                                    modContext (++ [Left $ Terminal $1])
                                    return [Terminal $1] }
        | terms_ ',' lsym       {% do
                                    assertContext (not . elem (Left $ Terminal $3)) "Duplicate terminal on definition"
                                    modContext (++ [Left $ Terminal $3])
                                    return $ Terminal $3 : $1 }

vars    :: {[Variable]}
        : '{' vars_ '}'                                   { $2 }
vars_   :: {[Variable]}
        : usym                  {% do
                                    modContext (++ [Right $ Variable $1])
                                    return [Variable $1] }
        | vars_ ',' usym        {% do 
                                    modContext (++ [Right $ Variable $3])
                                    return $ Variable $3 : $1 }

prods   :: {[Production]}
        : '{' prods_ '}'                                  { $2 }
prods_  :: {[Production]}
        : prod                                            { [$1] }
        | prods_ ',' prod                                 { $3 : $1 }

prod    :: {Production}
        : usym ':' lsyms maybeusym                        { Production (Variable $1) $3 $4 }

lsyms   :: {[Terminal]}
        : lsym                                             { [Terminal $1] }
        | lsyms lsym                                      { Terminal $2 : $1 }

maybeusym :: {Maybe Variable}
          : {- empty -}                                   { Nothing }
          | usym                                          { Just $ Variable $1 }
          
{
type Context = [Either Terminal Variable]

parseError :: [Token] -> PMonad Context a
parseError = throwError . show 

parse :: String -> Either String (Grammar, Context)
parse s = runPMonad (parser $ lexer s) mempty
}
