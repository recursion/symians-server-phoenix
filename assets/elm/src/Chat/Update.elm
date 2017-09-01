module Chat.Update exposing (update)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import Chat.Model exposing (..)
import Chat.Decoders exposing (..)

userParams : JE.Value
userParams =
  JE.object [ ( "user_id", JE.string "123" ) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    PhoenixMsg msg ->
      let
        ( phxSocket, phxCmd ) =
          Phoenix.Socket.update msg model.phxSocket
      in
        ( { model | phxSocket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )

    SendMessage ->
      let
        payload =
          (JE.object [ ( "user", JE.string "user" ), ( "body", JE.string model.newMessage ) ])

        push_ =
          Phoenix.Push.init "new:msg" "rooms:lobby"
              |> Phoenix.Push.withPayload payload

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.push push_ model.phxSocket
      in
        ( { model
            | newMessage = ""
            , phxSocket = phxSocket
          }
        , Cmd.map PhoenixMsg phxCmd
        )

    SetNewMessage str ->
      ( { model | newMessage = str }
      , Cmd.none
      )

    ReceiveJoinMessage raw ->
      case Chat.Decoders.decodeJoinMessage raw of
        Ok joinMessage ->
          let
            user = model.user
            next_user = { user | id = joinMessage.id
                        , token = joinMessage.token
                        , status = joinMessage.status
                        }
          in
            ({model | user = next_user}, Cmd.none)

        Err error ->
          ( model, Cmd.none )

    ReceiveChatMessage raw ->
      case Chat.Decoders.decodeChatMessage raw of
        Ok chatMessage ->
          ( { model | messages = (chatMessage.user ++ ": " ++ chatMessage.body) :: model.messages }
          , Cmd.none
          )

        Err error ->
          ( model, Cmd.none )

    JoinChannel ->
      let
        channel =
            -- We will need a port to communicate with location storage
            -- for the user tokens.
            Phoenix.Channel.init "rooms:lobby"
                |> Phoenix.Channel.withPayload userParams
                |> Phoenix.Channel.onJoin (always (ShowJoinedMessage "rooms:lobby"))
                |> Phoenix.Channel.onClose (always (ShowLeftMessage "rooms:lobby"))

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.phxSocket
      in
        ( { model | phxSocket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )

    LeaveChannel ->
      let
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.leave "rooms:lobby" model.phxSocket
      in
        ( { model | phxSocket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )

    ShowJoinedMessage channelName ->
      ( { model | messages = ("Joined channel " ++ channelName) :: model.messages }
      , Cmd.none
      )

    ShowLeftMessage channelName ->
      ( { model | messages = ("Left channel " ++ channelName) :: model.messages }
      , Cmd.none
      )

    NoOp ->
      ( model, Cmd.none )

