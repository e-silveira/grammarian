module PMonad(PMonad, viewContext, modContext, putContext, throwError, assertContext, runPMonad) where

import Control.Monad.State

type PMonad context a = StateT context (Either String) a



viewContext :: PMonad context context
viewContext = get -- função do StateT

modContext :: (context -> context) -> PMonad context ()
modContext = modify -- função do StateT

putContext :: context -> PMonad context ()
putContext = put 

runPMonad :: PMonad context a -> context -> Either String (a, context)
runPMonad = runStateT -- função do StateT

throwError :: String -> PMonad context a
throwError = lift . Left --função do Either, lift "eleva" o Left de 'Either String a' para o 'PMonad context a'

assertContext :: (context -> Bool) -> String -> PMonad context ()
assertContext f msg = do
  ctx <- viewContext
  if f ctx
    then return ()
    else throwError msg