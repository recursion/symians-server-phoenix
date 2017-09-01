defmodule SymiansServerWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rooms:*", SymiansServerWeb.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_params, socket) do
    case %{assigns: _assigns} = socket do
      {:ok, _token} ->
        IO.puts "Existing user connected"
        {:ok, socket}
      _ ->
        IO.puts "New User!"
        token = Phoenix.Token.sign(socket, "veruka salty dawg 4 lyfe", UUID.uuid1())
        changeset = SymiansServer.User.changeset(%SymiansServer.User{}, %{token: token})

        case SymiansServer.Repo.insert(changeset) do
          {:ok, user} ->
            IO.puts "reading user: #{inspect user.id}"

            socket = socket
                |> assign(:token, token)
                |> assign(:id, user.id)

            {:ok, socket}

          {:error, changeset} ->
            IO.puts "Could not add user -> #{inspect changeset}"
            {:ok, socket}
        end
    end
  end

  def handle_info({:user_connected, user}, socket) do
    IO.puts "UYIUDSFIOKLSUDF"
    IO.inspect user
    IO.puts "UYIUDSFIOKLSUDF"
    {:noreply, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     SymiansServerWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
