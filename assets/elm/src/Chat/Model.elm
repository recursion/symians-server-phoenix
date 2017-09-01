module Chat.Model exposing (Msg(..), Model, User, ChatMessage, JoinMessage, initModel, init )

import Phoenix.Socket
import Json.Encode as JE


-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"

type Msg
    = SendMessage
    | SetNewMessage String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveChatMessage JE.Value
    | ReceiveJoinMessage JE.Value
    | JoinChannel
    | LeaveChannel
    | ShowJoinedMessage String
    | ShowLeftMessage String
    | NoOp


type alias User =
    { id : Maybe Int
    , token : Maybe String
    , status : String
    }

type alias Model =
    { newMessage : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    , user : User
    }

type alias ChatMessage =
    { user : String
    , body : String
    }

type alias JoinMessage =
    { status: String
    , id : Maybe Int
    , token : Maybe String
    }


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



