module Main exposing (..)

import Html

type alias World =
  { snake : Snake
  , apple : Point
  }

type alias Snake =
  { body : List Point
  , speed : Float
  , delta : Float
  }

type alias Point = (Int, Int)

snake : Snake
snake =
  { body = [(0, 0)]
  , speed = 1
  , delta = 0
  }

world : World
world =
  { snake = snake
  , apple = (2, 2)
  }

view : World -> Html.Html String
view world = Html.div [] [ Html.text "Hello" ]

update : String -> World -> World
update _ world = world

-- main = Html.div [] [ Html.text "wow" ]
main = Html.beginnerProgram { model = world, update = update, view = view }
