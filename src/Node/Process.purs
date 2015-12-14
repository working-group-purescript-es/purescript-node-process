-- | Bindings to the global `process` object in Node.js. See also [the Node API documentation](https://nodejs.org/api/process.html)
module Node.Process
  ( PROCESS()
  , onBeforeExit
  , onExit
  , onSignal
  , argv
  , execArgv
  , execPath
  , chdir
  , cwd
  , getEnv
  , lookupEnv
  , setEnv
  , pid
  , platform
  , exit
  , stdin
  , stdout
  , stderr
  , stdoutIsTTY
  , version
  ) where

import Prelude
import Control.Monad.Eff
import Control.Monad.Eff.Console (CONSOLE())
import Control.Monad.Eff.Exception (EXCEPTION())
import Data.Maybe (Maybe())
import Data.Maybe.Unsafe (fromJust)
import Data.StrMap (StrMap())
import Data.StrMap as StrMap
import Node.Stream (Readable(), Writable())

import Node.Platform (Platform())
import Node.Platform as Platform

-- | An effect tracking interaction with the global `process` object.
foreign import data PROCESS :: !

-- YOLO
foreign import process :: forall props. { | props }

mutable :: forall eff a. a -> Eff eff a
mutable = pure

-- | Register a callback to be performed when the event loop empties, and
-- | Node.js is about to exit. Asynchronous calls can be made in the callback,
-- | and if any are made, it will cause the process to continue a little longer.
foreign import onBeforeExit :: forall eff. Eff (process :: PROCESS | eff) Unit -> Eff (process :: PROCESS | eff) Unit

-- | Register a callback to be performed when the process is about to exit.
-- | Any work scheduled via asynchronous calls made here will not be performed
-- | in time.
-- |
-- | The argument to the callback is the exit code which the process is about
-- | to exit with.
foreign import onExit :: forall eff. (Int -> Eff (process :: PROCESS | eff) Unit) -> Eff (process :: PROCESS | eff) Unit

-- | Install a handler for a particular signal.
foreign import onSignal :: forall eff. String -> Eff (process :: PROCESS | eff) Unit -> Eff (process :: PROCESS | eff) Unit

-- | Get an array containing the command line arguments. Be aware
-- | that this can change over the course of the program.
argv :: forall eff. Eff (process :: PROCESS | eff) (Array String)
argv = mutable process.argv

-- | Node-specific options passed to the `node` executable. Be aware that
-- | this can change over the course of the program.
execArgv :: forall eff. Eff (process :: PROCESS | eff) (Array String)
execArgv = mutable process.execArgv

-- | The absolute pathname of the `node` executable that started the
-- | process.
execPath :: forall eff. Eff (process :: PROCESS | eff) String
execPath = mutable process.execPath

-- | Change the current working directory of the process. If the current
-- | directory could not be changed, an exception will be thrown.
foreign import chdir :: forall eff. String -> Eff (err :: EXCEPTION, process :: PROCESS | eff) Unit

-- | Get the current working directory of the process.
cwd :: forall eff. Eff (process :: PROCESS | eff) String
cwd = process.cwd

-- | Get a copy of the current environment.
getEnv :: forall eff. Eff (process :: PROCESS | eff) (StrMap String)
getEnv = mutable process.env

-- | Lookup a particular environment variable.
lookupEnv :: forall eff. String -> Eff (process :: PROCESS | eff) (Maybe String)
lookupEnv k = StrMap.lookup k <$> getEnv

-- | Set an environment variable.
foreign import setEnv :: forall eff. String -> String -> Eff (process :: PROCESS | eff) Unit

pid :: Int
pid = process.pid

platform :: Platform
platform = fromJust (Platform.fromString process.platform)

-- | Cause the process to exit with the supplied integer code. An exit code
-- | of 0 is normally considered successful, and anything else is considered a
-- | failure.
foreign import exit :: forall eff. Int -> Eff (process :: PROCESS | eff) Unit

stdin :: forall eff. Readable () (console :: CONSOLE | eff)
stdin = process.stdin

stdout :: forall eff. Writable () (console :: CONSOLE | eff)
stdout = process.stdout

stderr :: forall eff. Writable () (console :: CONSOLE | eff)
stderr = process.stderr

-- | Check whether the process is being run inside a TTY context
stdoutIsTTY :: Boolean
stdoutIsTTY = process.stdout.isTTY

-- | Get the Node.js version.
version :: String
version = process.version
