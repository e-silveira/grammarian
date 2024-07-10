module PMonad(PMonad, viewContext, modContext, putContext, throwError, assertContext, runPMonad) where

import Control.Monad.State

type PMonad context a = StateT context (Either String) a

{--
Caro Eduardo,

Isso é um monad transformer. Ele é uma monada que "transforma" outro monada.
No caso, ele transforma a monada Either String em uma monada que também tem um estado.
Isso é equivalente a ter um:

data PMonad context a = PMonad (context -> (Either String a, context))

mas como eu já tenho as duas definições

data State context a = State (context -> (a, context))
data Either a b = Left a | Right b

, eu posso usar o StateT que deixa eu compor os dois.

data StateT s m a = StateT { runStateT :: s -> m (a,s) }

inclusive, o proprio State é um StateT com o Identity como monada base.

data State s a = StateT s Identity a
--}


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