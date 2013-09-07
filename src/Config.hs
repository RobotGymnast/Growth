{-# LANGUAGE NoImplicitPrelude
           , TupleSections
           #-}
-- | Settings are stored in this module
module Config ( viewDist
              , windowSize
              , boardDims
              , screenDims
              , displayOpts
              , title
              , keymap
              , clickAction
              , initBoard
              ) where

import Summit.Data.Array
import Summit.Data.List
import Summit.Data.Map
import Summit.Prelewd

import Data.Tuple

import Game.Input
import Game.Object
import Game.Object.Type
import Game.Vector
import Physics.Types
import Wrappers.Events
import Wrappers.GLFW (DisplayOptions (..), defaultDisplayOptions)

-- | Viewing distance of the camera
viewDist :: Int
viewDist = 3

windowSize :: Num a => (a, a)
windowSize = (400, 400)

-- | Dimensions of the whole board
boardDims :: Num a => Vector a
boardDims = Vector 64 32

-- | Dimensions of the segment of board to show on the screen
screenDims :: Num a => Vector a
screenDims = 32

-- | GLFW display options
displayOpts :: DisplayOptions
displayOpts = defaultDisplayOptions
    { displayOptions_width = fst windowSize
    , displayOptions_height = snd windowSize
    , displayOptions_windowIsResizable = False
    }

-- | Title of the game window
title :: Text
title = "Growth"

-- | What controls what?
keymap :: Map Key Input
keymap = map2 CharKey $ fromList
       [ (' ', Step)
       , ('F', Select Fire)
       , ('A', Select Air)
       , ('R', Select Rock)
       , ('S', Select Snow)
       ]

clickAction :: Position -> Input
clickAction = Place

data FullOrEmpty = I | X
    deriving (Eq)

initBoard :: Board
initBoard = listArray (0, boardDims - 1) (repeat Air)
          // [(Vector 29 0, Fire), (Vector 15 29, Fire)]
          // [(Vector i 31, Snow) | i <- [13..17]]
          // [(Vector (17 - i + j) (25 - i), Snow) | i <- [0..3], j <- [0 .. 2 * i]]
          // mapMaybe (\(b, p) -> mcond (b == X) (p, Rock))
                      (zip rocks [Vector x y | y <- reverse [0..31], x <- [0..31]])
    where
        rocks =
            [ I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, X, X, X, X, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, X, X, X, I, I, I, I, I, I, X, X, X, X, X, X, X, I, I, I, I, I, I, I
            , I, I, I, I, I, I, X, X, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, X, X, X, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, X, X, I, I
            , I, I, I, I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, X, I
            , I, I, I, X, X, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, X, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, X, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, X, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, X, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            , I, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, I, X, X, I
            , X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, I, X, I
            , X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, I, X, I
            , X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, I, X, I
            , I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I
            ]
