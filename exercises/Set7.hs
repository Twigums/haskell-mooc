-- Exercise set 7

module Set7 where

import Mooc.Todo
import Data.List
import Data.List.NonEmpty (NonEmpty ((:|)))
import Data.Monoid
import Data.Semigroup

------------------------------------------------------------------------------
-- Ex 1: you'll find below the types Time, Distance and Velocity,
-- which represent time, distance and velocity in seconds, meters and
-- meters per second.
--
-- Implement the functions below.

data Distance = Distance Double
  deriving (Show,Eq)

data Time = Time Double
  deriving (Show,Eq)

data Velocity = Velocity Double
  deriving (Show,Eq)

-- velocity computes a velocity given a distance and a time
velocity :: Distance -> Time -> Velocity
velocity (Distance x) (Time t) = Velocity (x / t)

-- travel computes a distance given a velocity and a time
travel :: Velocity -> Time -> Distance
travel (Velocity v) (Time t) = Distance (v * t)

------------------------------------------------------------------------------
-- Ex 2: let's implement a simple Set datatype. A Set is a list of
-- unique elements. The set is always kept ordered.
--
-- Implement the functions below. You might need to add class
-- constraints to the functions' types.
--
-- Examples:
--   member 'a' (Set ['a','b','c'])  ==>  True
--   add 2 (add 3 (add 1 emptySet))  ==>  Set [1,2,3]
--   add 1 (add 1 emptySet)  ==>  Set [1]

data Set a = Set [a]
  deriving (Show,Eq)

-- emptySet is a set with no elements
emptySet :: Set a
emptySet = Set []

-- member tests if an element is in a set
member :: Eq a => a -> Set a -> Bool
member e (Set []) = False
member e (Set (val : vals)) = if e == val then True else member e (Set vals)

-- add a member to a set
add :: Ord a => a -> Set a -> Set a
add e (Set vals) = Set (takeWhile (\x -> x < e) vals ++ [e] ++ dropWhile (\x -> x <= e) vals)

------------------------------------------------------------------------------
-- Ex 3: a state machine for baking a cake. The type Event represents
-- things that can happen while baking a cake. The type State is meant
-- to represent the states a cake can be in.
--
-- Your job is to
--
--  * add new states to the State type
--  * and implement the step function
--
-- so that they have the following behaviour:
--
--  * Baking starts in the Start state
--  * A successful cake (reperesented by the Finished value) is baked
--    by first adding eggs, then adding flour and sugar (flour and
--    sugar can be added in which ever order), then mixing, and
--    finally baking.
--  * If the order of Events differs from this, the result is an Error cake.
--    No Events can save an Error cake.
--  * Once a cake is Finished, it stays Finished even if additional Events happen.
--
-- The function bake just calls step repeatedly. It's used for the
-- examples below. Don't modify it.
--
-- Examples:
--   bake [AddEggs,AddFlour,AddSugar,Mix,Bake]  ==>  Finished
--   bake [AddEggs,AddFlour,AddSugar,Mix,Bake,AddSugar,Mix]  ==> Finished
--   bake [AddFlour]  ==>  Error
--   bake [AddEggs,AddFlour,Mix]  ==>  Error

data Event = AddEggs | AddFlour | AddSugar | Mix | Bake
  deriving (Eq,Show)

data State = Start | Error | EggsAdded | FlourAdded | SugarAdded | TwoAdded | Mixed | Finished
  deriving (Eq,Show)

step state event =
  case (state, event) of
    (Start, AddEggs) -> EggsAdded
    (EggsAdded, AddFlour) -> FlourAdded
    (EggsAdded, AddSugar) -> SugarAdded
    (FlourAdded, AddSugar) -> TwoAdded
    (SugarAdded, AddFlour) -> TwoAdded
    (TwoAdded, Mix) -> Mixed
    (Mixed, Bake) -> Finished
    (Finished, _) -> Finished
    (_, _) -> Error

-- do not edit this
bake :: [Event] -> State
bake events = go Start events
  where go state [] = state
        go state (e:es) = go (step state e) es

------------------------------------------------------------------------------
-- Ex 4: remember how the average function from Set4 couldn't really
-- work on empty lists? Now we can reimplement average for NonEmpty
-- lists and avoid the edge case.
--
-- PS. The Data.List.NonEmpty type has been imported for you
--
-- Examples:
--   average (1.0 :| [])  ==>  1.0
--   average (1.0 :| [2.0,3.0])  ==>  2.0

average :: Fractional a => NonEmpty a -> a
average (x :| xs) = (x + foldr (+) 0 xs) / fromIntegral (length xs + 1)

------------------------------------------------------------------------------
-- Ex 5: reverse a NonEmpty list.
--
-- PS. The Data.List.NonEmpty type has been imported for you

reverseNonEmpty :: NonEmpty a -> NonEmpty a
reverseNonEmpty (x :| []) = x :| []
reverseNonEmpty (x :| (y : ys)) = z :| (zs ++ [x])
  where (z :| zs) = reverseNonEmpty (y :| ys)

------------------------------------------------------------------------------
-- Ex 6: implement Semigroup instances for the Distance, Time and
-- Velocity types from exercise 1. The instances should perform
-- addition.
--
-- When you've defined the instances you can do things like this:
--
-- velocity (Distance 50 <> Distance 10) (Time 1 <> Time 2)
--    ==> Velocity 20

instance Semigroup Distance where
  Distance a <> Distance b = Distance (a + b)

instance Semigroup Time where
  Time a <> Time b = Time (a + b)

instance Semigroup Velocity where
  Velocity a <> Velocity b = Velocity (a + b)

------------------------------------------------------------------------------
-- Ex 7: implement a Monoid instance for the Set type from exercise 2.
-- The (<>) operation should be the union of sets.
--
-- What's the right definition for mempty?
--
-- What are the class constraints for the instances?

instance Ord a => Semigroup (Set a) where
  Set a <> Set [] = Set a
  Set a <> Set (b : bs) = add b (Set a <> Set bs)

instance Ord a => Monoid (Set a) where
  mempty = emptySet

------------------------------------------------------------------------------
-- Ex 8: below you'll find two different ways of representing
-- calculator operations. The type Operation1 is a closed abstraction,
-- while the class Operation2 is an open abstraction.
--
-- Your task is to add:
--  * a multiplication case to Operation1 and Operation2
--    (named Multiply1 and Multiply2, respectively)
--  * functions show1 and show2 that render values of
--    Operation1 and Operation2 to strings
--
-- Examples:
--   compute1 (Multiply1 2 3) ==> 6
--   compute2 (Multiply2 2 3) ==> 6
--   show1 (Add1 2 3) ==> "2+3"
--   show1 (Multiply1 4 5) ==> "4*5"
--   show2 (Subtract2 2 3) ==> "2-3"
--   show2 (Multiply2 4 5) ==> "4*5"

data Operation1 = Add1 Int Int
                | Subtract1 Int Int
                | Multiply1 Int Int
  deriving Show

compute1 :: Operation1 -> Int
compute1 (Add1 i j) = i+j
compute1 (Subtract1 i j) = i-j
compute1 (Multiply1 i j) = i * j

show1 :: Operation1 -> String
show1 o =
  case o of
    Add1 i j      -> show i ++ "+" ++ show j
    Subtract1 i j -> show i ++ "-" ++ show j
    Multiply1 i j -> show i ++ "*" ++ show j

data Add2 = Add2 Int Int
  deriving Show
data Subtract2 = Subtract2 Int Int
  deriving Show

data Multiply2 = Multiply2 Int Int
  deriving Show

class Operation2 op where
  compute2 :: op -> Int
  show2 :: op -> String

instance Operation2 Add2 where
  compute2 (Add2 i j) = i+j
  show2 (Add2 i j) = show i ++ "+" ++ show j

instance Operation2 Subtract2 where
  compute2 (Subtract2 i j) = i-j
  show2 (Subtract2 i j) = show i ++ "-" ++ show j

instance Operation2 Multiply2 where
  compute2 (Multiply2 i j) = i * j
  show2 (Multiply2 i j) = show i ++ "*" ++ show j

------------------------------------------------------------------------------
-- Ex 9: validating passwords. Below you'll find a type
-- PasswordRequirement describing possible requirements for passwords.
--
-- Implement the function passwordAllowed that checks whether a
-- password is allowed.
--
-- Examples:
--   passwordAllowed "short" (MinimumLength 8) ==> False
--   passwordAllowed "veryLongPassword" (MinimumLength 8) ==> True
--   passwordAllowed "password" (ContainsSome "0123456789") ==> False
--   passwordAllowed "p4ssword" (ContainsSome "0123456789") ==> True
--   passwordAllowed "password" (DoesNotContain "0123456789") ==> True
--   passwordAllowed "p4ssword" (DoesNotContain "0123456789") ==> False
--   passwordAllowed "p4ssword" (And (ContainsSome "1234") (MinimumLength 5)) ==> True
--   passwordAllowed "p4ss" (And (ContainsSome "1234") (MinimumLength 5)) ==> False
--   passwordAllowed "p4ss" (Or (ContainsSome "1234") (MinimumLength 5)) ==> True

data PasswordRequirement =
  MinimumLength Int
  | ContainsSome String    -- contains at least one of given characters
  | DoesNotContain String  -- does not contain any of the given characters
  | And PasswordRequirement PasswordRequirement -- and'ing two requirements
  | Or PasswordRequirement PasswordRequirement  -- or'ing
  deriving Show

passwordAllowed :: String -> PasswordRequirement -> Bool
passwordAllowed s (MinimumLength len) = if length s >= len then True else False 
passwordAllowed s (ContainsSome [c]) = elem c s
passwordAllowed s (ContainsSome (c : cs)) = elem c s || passwordAllowed s (ContainsSome cs)
passwordAllowed s (DoesNotContain cs) = not (passwordAllowed s (ContainsSome cs))
passwordAllowed s (And req1 req2) = passwordAllowed s req1 && passwordAllowed s req2
passwordAllowed s (Or req1 req2) = passwordAllowed s req1 || passwordAllowed s req2

------------------------------------------------------------------------------
-- Ex 10: a DSL for simple arithmetic expressions with addition and
-- multiplication. Define the type Arithmetic so that it can express
-- expressions like this. Define the functions literal and operation
-- for creating Arithmetic values.
--
-- Define two interpreters for Arithmetic: evaluate should compute the
-- expression, and render should show the expression as a string.
--
-- Examples:
--   evaluate (literal 3) ==> 3
--   render   (literal 3) ==> "3"
--   evaluate (operation "+" (literal 3) (literal 4)) ==> 7
--   render   (operation "+" (literal 3) (literal 4)) ==> "(3+4)"
--   evaluate (operation "*" (literal 3) (operation "+" (literal 1) (literal 1)))
--     ==> 6
--   render   (operation "*" (literal 3) (operation "+" (literal 1) (literal 1)))
--     ==> "(3*(1+1))"
--

data Arithmetic = Literal Integer | Add Arithmetic Arithmetic | Multiply Arithmetic Arithmetic
  deriving Show

literal :: Integer -> Arithmetic
literal val = Literal val

operation :: String -> Arithmetic -> Arithmetic -> Arithmetic
operation s a1 a2 = case s of
  "+" -> Add a1 a2
  "*" -> Multiply a1 a2

evaluate :: Arithmetic -> Integer
evaluate a = case a of
  Literal a1 -> a1
  Add (Literal a1) (Literal a2) -> a1 + a2
  Multiply (Literal a1) (Literal a2) -> a1 * a2
  Add (Literal a1) a2 -> a1 + evaluate a2
  Add a1 (Literal a2) -> evaluate a1 + a2
  Multiply (Literal a1) a2 -> a1 * evaluate a2
  Multiply a1 (Literal a2) -> evaluate a1 * a2
  Add a1 a2 -> evaluate a1 + evaluate a2
  Multiply a1 a2 -> evaluate a1 * evaluate a2

render :: Arithmetic -> String
render a = case a of
  Literal a1 -> show a1
  Add (Literal a1) (Literal a2) -> "(" ++ show a1 ++ "+" ++ show a2 ++ ")"
  Multiply (Literal a1) (Literal a2) -> "(" ++ show a1 ++ "*" ++ show a2 ++ ")"
  Add (Literal a1) a2 -> "(" ++ show a1 ++ "+" ++ render a2 ++ ")"
  Add a1 (Literal a2) -> "(" ++ render a1 ++ "+" ++ show a2 ++ ")"
  Multiply (Literal a1) a2 -> "(" ++ show a1 ++ "*" ++ render a2 ++ ")"
  Multiply a1 (Literal a2) -> "(" ++ render a1 ++ "*" ++ show a2 ++ ")"
  Add a1 a2 -> "(" ++ render a1 ++ "+" ++ render a2 ++ ")"
  Multiply a1 a2 -> "(" ++ render a1 ++ "*" ++ render a2 ++ ")"
