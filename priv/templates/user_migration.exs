defmodule <%= inspect schema.repo %>.Migrations.<%= Macro.camelize(schema.table) %> do
  use Ecto.Migration

  def change do
    create table(:<%= schema.table %>, primary_key: false) do

      add :id, :binary_id, primary_key: true
      add :username, :string
      add :email, :string
      add :asyncto_id, :string
      add :display_name, :string
      add :community, :string
      add :phone, :string
      add :about, :text
      add :profile_picture, :string

      timestamps()
    end
  end
end
