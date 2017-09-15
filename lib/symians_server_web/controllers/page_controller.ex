defmodule SymiansServerWeb.PageController do
  use SymiansServerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
