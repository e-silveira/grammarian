{-# LANGUAGE LambdaCase #-}
module Runner (run, recognizeProduction, runRWS) where

import Grammar
import Data.Maybe (mapMaybe)
import Control.Monad.RWS

data EvalTree a = LeafErr a | LeafOk a | Tree a [EvalTree a] deriving (Eq)

instance Show a => Show (EvalTree a) where
  show = showTree ""


showTree :: Show a => String -> EvalTree a -> String
showTree indent (LeafErr x) = indent ++ "LeafErr " ++ show x
showTree indent (LeafOk x)  = indent ++ "LeafOk " ++ show x
showTree indent (Tree x subtrees) = 
  indent ++ "Tree " ++ show x ++ "\n" ++ 
  concatMap (\subtree -> showTree (indent ++ "    ") subtree ++ "\n") subtrees


treeHasOk :: EvalTree a -> Bool
treeHasOk (LeafOk _) = True
treeHasOk (Tree _ ts) = any treeHasOk ts
treeHasOk _ = False

-------------------------------------------------------------------------------------------------------

recognizeTerminals :: [Terminal] -> String -> (Bool, String)
recognizeTerminals [] s = (True, s)
recognizeTerminals _ [] = (False, [])
recognizeTerminals (Terminal t : ts) (c : cs)
  | t == c = recognizeTerminals ts cs
  | otherwise = (False, c : cs)

recognizeProduction :: Production -> String -> Maybe (Maybe Variable, String)
recognizeProduction p s =
  case recognizeTerminals (string p) s of
    (True, rest) -> Just (to p, rest)
    (False, _) -> Nothing

recognizeVariable :: Grammar -> Variable -> String -> [EvalTree (Variable, String)]
recognizeVariable g v s
  | null nextNodes = [LeafErr (v, s)]
  | otherwise = [Tree (v,s) $ concatMap (\case 
                        (Just var, s1) -> recognizeVariable g var s1
                        (Nothing, "") -> pure $ LeafOk (v, mempty)
                        (Nothing, _) -> pure $ LeafErr (v,s)) nextNodes]
  where nextNodes = mapMaybe (`recognizeProduction` s) filteredProds
        filteredProds = filter (\p -> from p == v) $ productions g

-- recognizeVariableNoRec :: Grammar -> Variable -> String -> [(Variable, String)] -> [EvalTree (Variable, String)]
-- recognizeVariableNoRec g v s visited
--   | null nextNodes = [LeafErr (v, s)]
--   | otherwise = [Tree (v,s) evaluatedChildTrees]
--   where nextNodes = mapMaybe (`recognizeProduction` s) filteredProds
--         filteredProds = filter (\p -> from p == v) $ productions g
--         evaluatedChildTrees = 
--           concatMap (\case
--             (Just var, s1) -> 
--               if (var, s1) `elem` visited 
--                 then mempty
--                 else recognizeVariableNoRec g var s1 (visited++[(var,s1)])
--             (Nothing, "") -> pure $ LeafOk (v, mempty)
--             (Nothing, _) -> pure $ LeafErr (v,s)) nextNodes

run :: Grammar -> String -> IO () 
run g s = do
  if isAccepted 
    then putStrLn "Accepted" 
    else putStrLn "Rejected"
  print tree
  where 
    tree = head $ recognizeVariable g (start g) s
    isAccepted = treeHasOk tree
      