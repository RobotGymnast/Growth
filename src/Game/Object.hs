{-# LANGUAGE NoImplicitPrelude
           , TupleSections
           #-}
-- | Basic game object type, and associated functions
module Game.Object ( Object (..)
                   , Seeds
                   , Update
                   , object
                   , mix
                   ) where

import Prelewd hiding (all)

import Impure

import Control.Stream
import Data.Tuple
import Storage.Id
import Storage.List
import Storage.Pair
import Text.Show

import Game.Vector

data Object = Fire
            | Lava Bool
            | Grass
            | Water Bool
            | Air
            | Rock
    deriving (Show, Eq)

-- | Spawns from a set of neighbours
type Seeds = Vector (Pair (Maybe Object))
type Update = Stream Id Seeds Object

water :: Maybe Object -> Bool
water (Just (Water _)) = True
water _ = False

-- | What is travelling up in these Seeds?
up :: Seeds -> Maybe Object
(Vector _ (Pair _ up)) = getObj <$> dimensions <%> Pair snd fst
    where
        getObj dim f = f . pair (,) . component dim

precedence :: Object -> Object -> Int
precedence _ obj = length precList - (elemIndex obj precList <?> error ("No precedence for " <> show obj))
    where
        precList = [ Water True, Water False, Lava False, Fire, Grass, Rock, Air, Lava True ]

-- | Combine one object into another
mix :: Dimension -> Bool -> Object -> Object -> Object

mix _ _ Air (Lava False) = Rock

mix Height True Air (Water _) = Water False
mix Height True Rock (Water _) = Water True

mix _ _ Fire Grass = Fire
mix Height True Fire (Water _) = Water False

mix _ _ (Lava False) Grass = Fire
mix _ _ (Lava False) (Water _) = Air
mix _ _ (Lava False) Rock = Lava False

mix Height True (Lava True) Rock = Lava True
mix _ _ (Lava True) _ = Lava False

mix Height True (Water _) (Water _) = Water False
mix Height True (Water _) x = x
mix Width _ (Water False) x = x
mix Width _ (Water True) (Water _) = Water True
mix _ _ (Water b) Fire = Water b
mix _ _ (Water b) Air = Water b

mix _ _ Grass (Water _) = Grass

mix _ _ _ obj = obj

object :: Update
object = arr Just >>> updater updateObject (accum Air) >>> arr fst
    where
        accum obj = (obj, objectUpdate obj)
        updateObject seeds (obj, s) = nextAccum obj $ (Left <$> mixNeighbours obj seeds <?> Right ()) >> (s $< seeds)
        nextAccum obj = either accum $ (obj,) . snd

objectUpdate :: Object -> Stream (Either Object) Seeds ()

objectUpdate (Lava False) = lift $ arr $ \seeds -> iff (volcano seeds) (Left $ Lava True) $ Right ()
    where
        volcano (Vector (Pair (Just (Lava _)) (Just (Lava _))) (Pair (Just (Lava _)) (Just Rock))) = True
        volcano _ = False

objectUpdate (Water True) = lift $ arr $ \seeds -> iff (water $ up seeds) (Left $ Water False) $ Right ()

objectUpdate _ = pure ()

mixNeighbours :: Object -> Seeds -> Maybe Object
mixNeighbours obj s = let
            mixes = mix <$> dimensions <%> Pair True False
        in cast (/= obj) $ applyMixes $ toList ((,) <$$> mixes <**> s) >>= toList
    where
        applyMixes :: [(Object -> Object -> Object, Maybe Object)] -> Object
        applyMixes = foldr (\(a, b) -> a b) obj . sortBy (compare `on` precedence obj . snd) . mapMaybe sequence
