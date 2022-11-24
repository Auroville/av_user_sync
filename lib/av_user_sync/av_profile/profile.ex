defmodule AVUserSync.AVProfile.Profile do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field(:display_name, :string)
    field(:community, :string)
    field(:phone, :string)
    field(:about, :string)
    field(:asyncto_id, :string)
    field(:profile_picture, :string)
    field(:auroville_account_id, :binary_id)

    timestamps()
  end
end
