module Chat.Decoders exposing (..)
import Json.Decode as JD exposing (field)
import Chat.Model exposing (JoinMessage, ChatMessage)

joinMessageDecoder : JD.Decoder JoinMessage
joinMessageDecoder =
    JD.map3 JoinMessage
        (field "status" JD.string)
        (JD.maybe (field "id" JD.int))
        (JD.maybe (field "token" JD.string))

chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.map2 ChatMessage
        (field "user" JD.string)
        (field "body" JD.string)


decodeChatMessage = 
  JD.decodeValue chatMessageDecoder

decodeJoinMessage = 
  JD.decodeValue joinMessageDecoder
