defmodule Mix.AVUserSync.Schema do
  @moduledoc """
  Used for
  """

  @doc """
  Converts an attribute/form field into its humanize version.

  ## Examples

      iex> Phoenix.Naming.humanize(:username)
      "Username"
      iex> Phoenix.Naming.humanize(:created_at)
      "Created at"
      iex> Phoenix.Naming.humanize("user_id")
      "User"

  """
  @spec humanize(atom | String.t) :: String.t
  def humanize(atom) when is_atom(atom),
    do: humanize(Atom.to_string(atom))
  def humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> String.capitalize
  end


  @doc """
  Returns a map that is useful for creating a schema
  """
  def new(schema_name, schema_plural, opts) do
    ctx_app   = opts[:context_app] || Mix.AVUserSync.context_app()
    otp_app   = Mix.AVUserSync.otp_app()
    opts      = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base      = Mix.AVUserSync.context_base(ctx_app)
    basename  = Macro.underscore(schema_name)
    module    = Module.concat([base, schema_name])
    repo      = opts[:repo] || Module.concat([base, "Repo"])
    file      = Mix.AVUserSync.context_lib_path(ctx_app, basename <> ".ex")
    table     = schema_plural

    singular =
      module
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    collection = if schema_plural == singular, do: singular <> "_collection", else: schema_plural

    %{
      opts: opts,
      module: module,
      repo: repo,
      table: table,
      alias: module |> Module.split() |> List.last() |> Module.concat(nil),
      file: file,
      plural: schema_plural,
      singular: singular,
      collection: collection,
      human_singular: humanize(singular),
      human_plural: humanize(schema_plural),
      sample_id: "11111111-1111-1111-1111-111111111111",
      context_app: ctx_app,
      otp_app: otp_app,
      migration_module: migration_module(),
      prefix: opts[:prefix]
    }
  end

  defp migration_module do
    case Application.get_env(:ecto_sql, :migration_module, Ecto.Migration) do
      migration_module when is_atom(migration_module) -> migration_module
      other -> Mix.raise "Expected :migration_module to be a module, got: #{inspect(other)}"
    end
  end

end
