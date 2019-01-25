module TUI where

import Brick
import Brick.Widgets.Center
import Brick.Widgets.Border
import Brick.Widgets.Border.Style
-- import Data.IORef

ui :: String -> Widget ()
ui x = withBorderStyle unicode $
       borderWithLabel (str x) $
       center (str x) <+> vBorder <+> center (str x)
