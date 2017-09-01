defmodule SymiansServerWeb.PageController do
  use SymiansServerWeb, :controller

  def index(conn, _params) do
    locations = Syms.World.generate_locations({5, 5, 5})
    render conn, "index.html", locations: locations
  end
end
