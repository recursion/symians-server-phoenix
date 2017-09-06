defmodule SymiansServerWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "system:*", SymiansServerWeb.Channels.System

  # Transports
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

  # TODO: move this into a config file.. or something more secure...
  @salt "veruka salty dawg 4 lyfe yo"

  def connect(params, socket) do
    case params do
      %{token: _token} ->
        IO.puts "Existing user connected"
        # validate token - and attach to socket if its good
        {:ok, socket}
      _ ->
        IO.puts "New user connected"
        # just create him a token for now
        # we will do some further 'sign up' later if needed
        {:ok, assign_token(socket)}
    end
  end

  def assign_token(socket) do
    socket
    |> assign(:token, Phoenix.Token.sign(socket, @salt, UUID.uuid1()))
    |> assign(:user_name, get_random_anon_user())
  end

  def get_random_anon_user do
    :random.seed(:erlang.now)
    Enum.random(["A wandering stranger", "An unknown soldier", "Some passerbyer"])
  end

  def authenticate(socket, token) do
    Phoenix.Token.verify(socket, @salt, token)
  end

  def create_user(token) do
    %SymiansServer.User{}
    |> SymiansServer.User.changeset(token)
    |> SymiansServer.Repo.insert!
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
