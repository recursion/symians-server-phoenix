module Chat.Subscriptions exposing (subscriptions)

import Phoenix.Socket
import Chat.Model exposing (Model, Msg(PhoenixMsg))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [Phoenix.Socket.listen model.phxSocket PhoenixMsg]



