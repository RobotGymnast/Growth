{-# LANGUAGE NoImplicitPrelude
           #-}
-- | Basic game object type, and associated functions
module Game.Object ( Object (..)
                   , Spawn
                   , spawn
                   , mix
                   ) where

import Prelewd hiding (all)

import Text.Show

import Game.Vector

data Object = Fire
            | Lava
            | Grass
            | Water
            | Air
            | Rock
    deriving (Show, Eq, Ord)

-- | The directions in which to spawn
type Spawn = Vector (Maybe Object, Maybe Object)

all, gravity :: Object -> Spawn

all o = pure (Just o, Just o)
gravity = component' Height (map $ \_-> Nothing) . all

-- | What does an Object produce in neighbouring cells?
spawn :: Object -> Spawn
spawn Fire = all Fire
spawn Lava = all Lava
spawn Grass = all Grass
spawn Water = gravity Water
spawn Air = all Air
spawn Rock = all Rock

-- | Combine two overlapping Objects two produce a new one.
mix :: Object -> Object -> Object

mix Water Lava = Rock
mix _ Lava = Lava

mix Lava Rock = Lava
mix _ Rock = Rock

mix Air x = x
mix Rock x = x

mix Fire Fire = Fire
mix Fire Grass = Fire
mix Fire Water = Water
mix Fire Air = Air

mix Lava Fire = Fire
mix Lava Grass = Fire
mix Lava Water = Lava
mix Lava Air = Air

mix Water Fire = Air
mix Water Grass = Grass
mix Water Water = Water
mix Water Air = Water

mix Grass Fire = Fire
mix Grass Grass = Grass
mix Grass Water = Grass
mix Grass Air = Air
