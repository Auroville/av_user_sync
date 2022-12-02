defmodule Mix.AVUserSync.Schema do
  @moduledoc """
  TODO: Write better documentation for this module
  """

  @doc """
  Returns a map that is useful for creating a schema
  """
  def new(schema_name, schema_plural, opts) do
    # The only reason to have opts as the third argument is to be able to use custom context app and custom repo

    ctx_app   = opts[:context_app] || Mix.AVUserSync.context_app()
    otp_app   = Mix.AVUserSync.otp_app()
    base      = Mix.AVUserSync.context_base(ctx_app)
    basename  = Macro.underscore(schema_name)
    module    = Module.concat([base, schema_name])
    repo      = opts[:repo] || Module.concat([base, "Repo"])
    file      = Mix.AVUserSync.context_lib_path(ctx_app, basename <> ".ex")
    table     = schema_plural

    %{
      module: module,
      repo: repo,
      table: table,
      file: file,
      context_app: ctx_app,
      otp_app: otp_app,
      migration_module: migration_module()
    }
  end

  defp migration_module do
    case Application.get_env(:ecto_sql, :migration_module, Ecto.Migration) do
      migration_module when is_atom(migration_module) -> migration_module
      other -> Mix.raise "Expected :migration_module to be a module, got: #{inspect(other)}"
    end
  end

end
