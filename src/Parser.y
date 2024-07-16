{
module Parser where

import Grammar
import Lexer
import PMonad
import Control.Monad (when)
import Debug.Trace (trace) 
}

%name parser 
%tokentype { Token }
%error { parseError }
%monad { PMonad Context } { (>>=) } { return }

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
          : lsym                  {% do 
                                    addTerm (Terminal $1)
                                    return [Terminal $1]}
          | lsym ',' terms_       {% do   
                                    addTerm $ Terminal $1
                                    return $ Terminal $1 : $3 }

vars      :: { [Variable] }
          : '{' vars_ '}'                             { $2 }

vars_     :: { [Variable] }
          : usym                 {% do
                                    addVar $ Variable $1
                                    return [Variable $1]}
          | usym ',' vars_       {% do
                                    addVar $ Variable $1 
                                    return $ Variable $1 : $3 }

prods     :: { [Production] }
          : '{' prods_ '}'                            { $2 }

prods_    :: { [Production] }
          : prod                                   {% do 
                                                      addProd $1
                                                      return [$1] }
          | prod ',' prods_                        {% do
                                                      addProd $1
                                                      return $ $1 : $3 }

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

data Context = Context { terms :: [Terminal], vars :: [Variable], prods :: [Production] } deriving(Show)


addTerm :: Terminal -> PMonad Context ()
addTerm t = do 
      Context ts vs ps <- get
      if t `elem` ts then error $ "terminal " ++ show t ++ " already defined"
      else put $ Context (t:ts) vs ps

addVar :: Variable -> PMonad Context ()
addVar v = do 
      Context ts vs ps <- get
      if v `elem` vs then error $ "non-terminal \"" ++ show v ++ "\" already defined"
      else put $ Context ts (v:vs) ps

addProd :: Production -> PMonad Context ()
addProd p@(Production from word to) = do 
      Context ts vs ps <- get
      if (p `elem` ps) 
      then error $ "production " ++ show p ++ " defiend twice"
      else if (from `notElem` vs) 
      then error $ "non-terminal " ++ show from ++ " used but not defined"
      else if (any (\t -> t `notElem` ts) word) 
      then error $ "terminal used but not defined"
      else put $ Context ts vs (p:ps)

parseError :: [Token] -> PMonad Context a
parseError tk = error $ "grammar parsing error" ++ show tk

parse :: String -> (Grammar, Context)
parse s = runState (parser $ lexer s) (Context [] [] [])
}
