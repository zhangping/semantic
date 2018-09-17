module Data.Reprinting.Token
  ( Token (..)
  , isChunk
  , isControl
  , Element (..)
  , Control (..)
  , Context (..)
  , imperativeDepth
  , precedenceOf
  , Operator (..)
  ) where

import Data.Text (Text)
import Data.Source (Source)

-- | 'Token' encapsulates 'Element' and 'Control' tokens, as well as sliced
-- portions of the original 'Source' for a given AST.
data Token
  = Chunk Source     -- ^ Verbatim 'Source' from AST, unmodified.
  | TElement Element -- ^ Content token to be rendered.
  | TControl Control -- ^ AST's context.
    deriving (Show, Eq)

isChunk :: Token -> Bool
isChunk (Chunk _) = True
isChunk _ = False

isControl :: Token -> Bool
isControl (TControl _) = True
isControl _ = False

-- | 'Element' tokens describe atomic pieces of source code to be
-- output to a rendered document. These tokens are language-agnostic
-- and are interpreted into language-specific representations at a
-- later point in the reprinting pipeline.
data Element
  = Run Text      -- ^ A literal chunk of text.
  | Truth Bool    -- ^ A boolean value.
  | Nullity       -- ^ @null@ or @nil@ or some other zero value.
  | TSep          -- ^ Some sort of delimiter, interpreted in some 'Context'.
  | TSym          -- ^ Some sort of symbol, interpreted in some 'Context'.
  | TThen
  | TElse
  | TOpen         -- ^ The beginning of some 'Context', such as an @[@ or @{@.
  | TClose        -- ^ The opposite of 'TOpen'.
    deriving (Eq, Show)

-- | 'Control' tokens describe information about some AST's context.
-- Though these are ultimately rendered as whitespace (or nothing) on
-- the page, they are needed to provide information as to how deeply
-- subsequent entries in the pipeline should indent.
data Control
  = Enter Context
  | Exit Context
  | Log String
    deriving (Eq, Show)

-- | A 'Context' represents a scope in which other tokens can be
-- interpreted. For example, in the 'Imperative' context a 'TSep'
-- could be a semicolon or newline, whereas in a 'List' context a
-- 'TSep' is probably going to be a comma.
data Context
  = TList
  | THash
  | TPair
  | TMethod
  | TFunction
  | TCall
  | TParams
  | TReturn
  | TIf
  | TInfixL Operator Int
  | Imperative
    deriving (Show, Eq)

precedenceOf :: [Context] -> Int
precedenceOf cs = case filter isInfix cs of
  (TInfixL _ n:_) -> n
  _ -> 0
  where isInfix (TInfixL _ _) = True
        isInfix _             = False


-- | Depth of imperative scope.
imperativeDepth :: [Context] -> Int
imperativeDepth = length . filter (== Imperative)

-- | A sum type representing every concievable infix operator a
-- language can define. These are handled by instances of 'Concrete'
-- and given appropriate precedence.
data Operator
  = Add
  | Multiply
  | Subtract
    deriving (Show, Eq)