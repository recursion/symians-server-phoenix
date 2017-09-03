defmodule SymiansServerWeb.DefaultChannel do
  require Logger
  use Phoenix.Channel
  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("rooms:lobby", message, socket) do
    IO.puts "User joined rooms:lobby"
    Process.flag(:trap_exit, true)
    # :timer.send_interval(5000, :ping)
    send(self(), {:after_join, message})
    {:ok, socket}
  end

  def join("rooms:secret", message, socket) do
    Process.flag(:trap_exit, true)
    # :timer.send_interval(5000, :ping)
    IO.puts "User joined Secret room! #{inspect message}"
    # send(self(), {:after_join, message})

    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, msg}, socket) do
    IO.puts "Recieved :after_join msg of -> #{inspect msg}"
    case socket.assigns do
      %{id: id, token: token} ->
        broadcast! socket, "user:entered", %{id: id}
        push socket, "join", %{status: "connected", id: id, token: token}
      %{token: token} ->
        push socket, "join", %{status: "connected", token: token}
    end
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    IO.puts "In handle_in `new:msg`"
    # get the users name
    # for now its anon
    IO.inspect msg
    broadcast! socket, "new:msg", %{user: "A wandering stranger", body: msg["body"]}
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end
end
