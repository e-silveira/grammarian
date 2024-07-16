module PMonad(PMonad, get, put, modify, evalState, runState) where

import Control.Monad.State

type PMonad context a = State context a

