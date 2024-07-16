import Data.Maybe (mapMaybe)


recognizeTerminals :: [Terminal] -> String -> (Bool, String)
recognizeTerminals [] s = (True, s)
recognizeTerminals _ [] = (False, [])
recognizeTerminals (Terminal t : ts) (c : cs)
  | t == c = recognizeTerminals ts cs
  | otherwise = (False, c : cs)

recognizeProduction :: Production -> String -> Maybe (Maybe Variable, String)
recognizeProduction p s
  | recognized = Just (to p, rest)
  | otherwise = Nothing
  where
    (recognized, rest) = recognizeTerminals (string p) s

recognize' :: Grammar -> Maybe Variable -> String -> Bool
recognize' _ Nothing _ = False
recognize' g (Just v) s = recognize g v s

recognize :: Grammar -> Variable -> String -> Bool
recognize g v s
  | (Nothing, "") `elem` rp = True
  | null rp = False
  | otherwise = any (uncurry (recognize' g)) rp
  where
    pp = filter (\p -> from p == v) (productions g)
    rp = mapMaybe (`recognizeProduction` s) pp
