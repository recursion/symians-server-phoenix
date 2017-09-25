defmodule SymiansServerWeb.Channels.System do
  require Logger
  use Phoenix.Channel
  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("system:", message, socket) do
    Process.flag(:trap_exit, true)
    # :timer.send_interval(5000, :ping)
    send(self(), {:send_auth_data, message})
    send(self(), :send_world_data)
    # :timer.send_interval(25000, :send_world_data)
    {:ok, socket}
  end

  def join("system:chat", message, socket) do
    Process.flag(:trap_exit, true)
    # TODO: use a timer send to schedule sending world data to connected users
    # :timer.send_interval(5000, :ping)
    IO.puts "User joined System chat! #{inspect message}"

    # send(self(), {:after_join, message})
    {:ok, socket}
  end

  def join("system" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:send_auth_data, msg}, socket) do
    IO.puts "Got handle_info message of: #{inspect msg}"
    push socket, "token", %{status: "connected", token: socket.assigns.token}
    {:noreply, socket}
  end

  def handle_info(:send_world_data, socket) do
    case :ets.lookup(String.to_atom("default"), "locations") do
      [{_, locations}] ->
        [{_, {l, w, h}}] = :ets.lookup(String.to_atom("default"), "dimensions")
        send_locations(locations, socket, {l, w, h})
        {:noreply, socket}
      _ ->
        # IO.puts "World not generated yet - delaying world send by 100ms"
        :timer.send_after(100, :send_world_data)
        {:noreply, socket}
    end

  end

  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def ets_lookup(world_name, key) do
    IO.inspect :ets.lookup(String.to_atom(world_name), key)
  end

  # send location data to client
  def send_locations(locations, socket, {l, w, h}) do
    Task.start(fn ->
      push socket, "world",
          %{locations: (getClientView locations),
            dimensions: %{length: l, width: w, height: h}
           }
    end)
  end

  # TODO: This may belong on the symulator module itself?
  # generate coordinates within the clients view
  # return the location data for those coordinates
  def getClientView(locations) do
    for x <- 0..50,
      y <- 0..50,
      z <- 0..3,
      into: %{},
      do: wrapLocation({x, y, z}, locations)
  end

  # gets a location from a map of locations
  # and wraps that location and its coordinates
  # into a keymap
  def wrapLocation({x, y, z}, locations) do
    {:ok, location} = Map.fetch(locations, {x, y, z})
    {Symulator.World.Coordinates.to_string({x, y, z}), location}
  end

  def terminate(reason, _socket) do
    Logger.debug "> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    # get the users name
    # for now its anon
    # TODO: setup proper naming structure / usage here
    user_name = socket.assigns.user_name
    message = %{user: user_name, body: msg["body"]}
    broadcast! socket, "new:msg", message
    {:reply, {:ok, message}, assign(socket, :user, msg["user"])}
  end
end
