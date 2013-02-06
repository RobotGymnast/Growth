{-# LANGUAGE NoImplicitPrelude
           #-}
-- | Settings are stored in this module
module Config ( viewDist
              , displayOpts
              , title
              , keymap
              , clickAction
              ) where

import Prelewd

import Storage.Map

import Game.Object
import Game.State
import Physics.Types
import Wrappers.Events
import Wrappers.GLFW (DisplayOptions (..), defaultDisplayOptions)

-- | Viewing distance of the camera
viewDist :: Int
viewDist = 3

-- | GLFW display options
displayOpts :: DisplayOptions
displayOpts = defaultDisplayOptions
    { displayOptions_width = 800
    , displayOptions_height = 800
    , displayOptions_windowIsResizable = False
    }

-- | Title of the game window
title :: Text
title = "Game"

-- | What controls what?
keymap :: Map Key Input
keymap = mapKeys CharKey $ fromList
       [ (' ', Step)
       , ('A', Select $ Water True False)
       , ('S', Select Rock)
       , ('D', Select Fire)
       ]

clickAction :: Position -> Input
clickAction = Place
