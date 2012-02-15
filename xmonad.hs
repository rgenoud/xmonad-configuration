-- from http://haskell.org/haskellwiki/Xmonad/Config_archive/Template_xmonad.hs_(0.8)

import XMonad
import System.Exit
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.EwmhDesktops
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map as M
 
myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat
    , className =? "Vncviewer" --> doFloat
    , className =? "Iceweasel" --> doShift "1"
    , (className =? "Iceweasel" <&&> resource =? "Dialog") --> doFloat
    , (className =? "Iceweasel" <&&> title =? "Téléchargements") --> doFloat
    , className =? "Pidgin" --> doShift "12"
    ]

startup :: X ()
startup = do
    spawn "pidof firefox-bin || iceweasel"
    spawn "pidof pidgin || pidgin"
    -- spawn "pidof gnome-panel || gnome-panel"
    spawn "pidof nm-applet || nm-applet"
    spawn "dontlaunch=0; for i in `pidof perl` ; do grep -q checkgmail /proc/$i/cmdline && dontlaunch=1; done; test $dontlaunch -eq 0 && checkgmail -no_cookies"
    spawn "pidof kerneloops-applet || kerneloops-applet"
    spawn "pidof update-notifier || update-notifier"
    spawn "pidof gnome-screensaver || gnome-screensaver"
    spawn "dontlaunch=0; for i in `pidof python` ; do grep -q system-config-printer-applet /proc/$i/cmdline && dontlaunch=1; done; test $dontlaunch -eq 0 && system-config-printer-applet"
    spawn "pidof trayer || trayer --edge top --align right --widthtype percent --width 10 --height 17 --tint 0 --transparent true --alpha 1 --SetDockType true"
    --spawn "pidof xautolock || xautolock -time 60 -locker \"sudo pm-suspend\""
    spawn "pidof mount-tray || mount-tray"
    spawn "dontlaunch=0; for i in `pidof python` ; do grep -q pidgin_evt_dump.py /proc/$i/cmdline && dontlaunch=1; done; test $dontlaunch -eq 0 && pidgin_evt_dump.py | xmobar /home/$USER/.xmonad/xmobar-bottom"
-- to test : runOrRaise "chromium" (className =? "Chromium")

myWorkspaces = map show [1 .. 12 :: Int]
 
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")
    -- close focused window 
    -- , ((modm .|. shiftMask, xK_c     ), kill) -- default
    , ((modm, xK_F4     ), kill)
     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    -- toggle the status bar gap (used with avoidStruts from Hooks.ManageDocks)
    -- , ((modm , xK_b ), sendMessage ToggleStruts)
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    -- Restart xmonad
    , ((modm              , xK_q     ), restart "xmonad" True)
    ]
    ++
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    -- My configuration
    [
    -- launch a terminal
    ((modm, xK_t), spawn $ XMonad.terminal conf)
    -- switch to US layout keyboard
    , ((modm .|. shiftMask, xK_e), spawn "setxkbmap -layout us")
    -- switch to FR layout keyboard
    , ((modm .|. shiftMask, xK_f), spawn "setxkbmap -layout fr")
    -- master volume up
    , ((modm, xK_KP_Add), spawn "amixer set Master 5%+")
    -- master volume down
    , ((modm, xK_KP_Subtract), spawn "amixer set Master 5%-")
    -- lock screen
    , ((controlMask .|. shiftMask, xK_l), spawn "gnome-screensaver-command -l")
    , ((modm .|. shiftMask, xK_l), spawn "gnome-screensaver-command -l")
    -- suspend and lock screen
    , ((controlMask .|. shiftMask .|. modm, xK_l), spawn "gnome-screensaver-command -l & sudo pm-suspend")
    -- floating layer support
    , ((modm .|. shiftMask, xK_t), withFocused $ windows . W.sink) -- %! Push window back into tiling
    ]
    ++
    -- switch workspaces azerty
    -- mod-[1..9] @@ Switch to workspace N
    -- mod-shift-[1..9] @@ Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf)
            [ xK_ampersand, xK_eacute, xK_quotedbl, xK_apostrophe, xK_parenleft, xK_minus
             , xK_egrave, xK_underscore, xK_ccedilla, xK_agrave, xK_parenright, xK_equal ]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ ewmh defaultConfig -- ewmh prevents the libreoffice bug on dialogs (focus flickering)
        { manageHook = manageDocks <+> myManageHook -- make sure to include myManageHook definition from above
                        <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        -- , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , terminal = "gnome-terminal" -- "urxvtc -tr -sh 30"
        , workspaces = myWorkspaces
        , startupHook = startup

        , keys = myKeys
        }
