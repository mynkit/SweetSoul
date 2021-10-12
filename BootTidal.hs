:set -XOverloadedStrings
:set prompt ""

import qualified Sound.Tidal.Tempo as T
import Sound.Tidal.Context
import System.IO (hSetEncoding, stdout, utf8)
hSetEncoding stdout utf8

-- total latency = oLatency + cFrameTimespan
tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/20})

:{
let p = streamReplace tidal
    hush = streamHush tidal
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    first = streamFirst tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    setcps = asap . cps
    xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
    xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
    histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
    wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
    waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
    jump i = transition tidal True (Sound.Tidal.Transition.jump) i
    jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
    jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
    jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
    mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
    interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
    interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
    clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
    clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
    anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
    anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
    forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i
    d1 = p 1 . (|< orbit 0)
    d2 = p 2 . (|< orbit 1)
    d3 = p 3 . (|< orbit 2)
    d4 = p 4 . (|< orbit 3)
    d5 = p 5 . (|< orbit 4)
    d6 = p 6 . (|< orbit 5)
    d7 = p 7 . (|< orbit 6)
    d8 = p 8 . (|< orbit 7)
    d9 = p 9 . (|< orbit 8)
    d10 = p 10 . (|< orbit 9)
    d11 = p 11 . (|< orbit 10)
    d12 = p 12 . (|< orbit 11)
    d13 = p 13
    d14 = p 14
    d15 = p 15
    d16 = p 16
:}

:{
let setI = streamSetI tidal
    setF = streamSetF tidal
    setS = streamSetS tidal
    setR = streamSetR tidal
    setB = streamSetB tidal
:}

:{
reverb = pF "reverb"
ice = pF "ice"
:}

:{
let elem' xs x = elem x xs
:}

:{
let resetCyclesTo n = T.changeTempo (sTempoMV tidal) (\t tempo -> tempo {T.atTime = t, T.atCycle = n})
:}

:{
let
  -- degeesUpC up n: Cメジャーキーで音程nの(up-1)度上の音階を返す
  degeesUpC 0 n = n
  degeesUpC up 1 = (degeesUpC up 0) + 1
  degeesUpC up 3 = (degeesUpC up 2) + 1
  degeesUpC up 6 = (degeesUpC up 5) + 1
  degeesUpC up 8 = (degeesUpC up 7) + 1
  degeesUpC up 10 = (degeesUpC up 9) + 1
  degeesUpC up 2 = degeesUpC (up+1) 0
  degeesUpC up 4 = degeesUpC (up+2) 0
  degeesUpC up 5 = degeesUpC (up+3) 0
  degeesUpC up 7 = degeesUpC (up+4) 0
  degeesUpC up 9 = degeesUpC (up+5) 0
  degeesUpC up 11 = degeesUpC (up+6) 0
  degeesUpC (-7) 0 = -12
  degeesUpC (-6) 0 = -10
  degeesUpC (-5) 0 = -8
  degeesUpC (-4) 0 = -7
  degeesUpC (-3) 0 = -5
  degeesUpC (-2) 0 = -3
  degeesUpC (-1) 0 = -1
  degeesUpC 1 0 = 2
  degeesUpC 2 0 = 4
  degeesUpC 3 0 = 5
  degeesUpC 4 0 = 7
  degeesUpC 5 0 = 9
  degeesUpC 6 0 = 11
  degeesUpC 7 0 = 12
  degeesUpC 8 0 = 14
  degeesUpC 9 0 = 16
  degeesUpC 10 0 = 17
  degeesUpC 11 0 = 19
  degeesUpC 12 0 = 21
  degeesUpC 13 0 = 23
  degeesUpC up n = degeesUpC up (n + 12) - 12
  -- harmonizer
  -- c: 0, cs: 1, d: 2, ef: 3, e: 4, f: 5
  -- fs: 6, g: 7, af: 8, a: 9, bf: 10, b: 11
  harmonizer key up n
    | up <= 7 && up >= (-7) = key + degeesUpC up (n - key)
    | up > 7 = key + degeesUpC 7 (n - key)
    | up < (-7) = key + degeesUpC (-7) (n - key)
:}

:set prompt "tidal> "
:set prompt-cont ""
