module Main exposing(..)
import Html exposing (Html)
import App.Model exposing (..)
import App.View exposing (view)
import App.Update exposing (update)
import Phoenix.Socket


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


-- MAIN

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [Phoenix.Socket.listen model.phxSocket PhoenixMsg]


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "rooms:lobby" ReceiveChatMessage
        |> Phoenix.Socket.on "join" "rooms:lobby" ReceiveJoinMessage


initModel : Model
initModel =
    Model "" [] initPhxSocket (User Nothing Nothing "")


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )

