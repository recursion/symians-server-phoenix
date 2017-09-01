defmodule SymiansServer.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias SymiansServer.User


  schema "users" do
    field :email, :string
    field :name, :string
    field :token, :string
    field :provider, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :token])
    |> validate_required([:token])
  end
end
