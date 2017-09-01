module Main exposing(..)
import Html exposing (Html, div)
import Platform.Cmd
import Json.Encode as JE
import Json.Decode as JD exposing (field)

import Chat.Model as ChatModel
import Chat.View as ChatView
import Chat.Update as Chat
import Chat.Subscriptions as ChatSubs


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


-- MODEL


type Msg
    = ChatMsg ChatModel.Msg
    | NoOp

type alias Model =
    { chat : ChatModel.Model }

initialModel : Model
initialModel =
    { chat = ChatModel.initModel }

init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
      [ Sub.map ChatMsg (ChatSubs.subscriptions model.chat) ]


type alias ChatMessage =
    { user : String
    , body : String
    }


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.map2 ChatMessage
        (field "user" JD.string)
        (field "body" JD.string)


-- UPDATE


userParams : JE.Value
userParams =
    JE.object [ ( "user_id", JE.string "123" ) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChatMsg msg ->
            let
                ( chat , chatCmd ) =
                    Chat.update msg model.chat
            in
                ( { model | chat = chat }
                , Cmd.map ChatMsg chatCmd
                )
        NoOp ->
          ( model, Cmd.none )


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.map ChatMsg (ChatView.view model.chat)
        ]
