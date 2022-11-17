defmodule <%= inspect schema.module %> do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema <%= inspect schema.table %> do

    field :about, :string
    field :asyncto_id, :string
    field :community, :string
    field :display_name, :string
    field :email, :string
    field :phone, :string
    field :profile_picture, :string
    field :username, :string

    timestamps()
  end
end
