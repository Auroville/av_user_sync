defmodule AVUserSync.AVAccounts.User do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:asyncto_id, :string)
  end
end
