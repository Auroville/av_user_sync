defmodule Mix.Tasks.AvUserSync.Gen.Schema do
  use Mix.Task

  alias Mix.AVUserSync.Schema

  @shortdoc "Generates schema and migration for user"
  @moduledoc @shortdoc


  @switches []


  @doc false
  def run(argv) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix av_user_sync.gen.schema must be invoked from within your *_web application root directory")
    end

    schema = build(argv)

    prompt_for_conflicts(schema)

    schema
    |> copy_new_files()
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(schema) do
    schema
    |> files_to_be_generated()
    |> Mix.AVUserSync.prompt_for_conflicts()
  end

  @doc false
  def build(argv) do
    {_, parsed, _} = OptionParser.parse(argv, switches: @switches)

    {schema_name, plural} = validate_args!(parsed)


    schema = Schema.new(schema_name, plural, [])
  end

  @doc false
  def files_to_be_generated(%{file: file} = _schema) do
    [{:eex, "schema.ex", file}]
  end

  @doc false
  def copy_new_files(%{context_app: ctx_app} = schema) do
    priv_directory = :code.priv_dir(:av_user_sync) |> String.Chars.to_string()

    schema_source = priv_directory <> "/templates/user_schema.ex"
    migration_source = priv_directory <> "/templates/user_migration.exs"

    schema_source = if File.exists?(schema_source), do: schema_source || raise "could not find the #{schema_source}"
    migration_source = if File.exists?(migration_source), do: migration_source || raise "could not find the #{migration_source}"

    schema_target = schema.file
    Mix.Generator.create_file(schema.file, EEx.eval_file(schema_source, schema: schema))

    migration_target = Mix.AVUserSync.context_app_path(ctx_app, "priv/repo/migrations/#{timestamp()}_create_#{schema.table}.exs")
    Mix.Generator.create_file(migration_target, EEx.eval_file(migration_source, schema: schema))

    schema
  end

  @doc false
  def validate_args!([]) do
    {"Accounts.User", "users"}
  end

  @doc false
  def validate_args!([schema, plural | remaining] = args) do
    cond do
      not valid_schema?(schema) ->
        raise_with_help "Expected the schema argument, #{inspect schema}, to be a valid module name"

      String.contains?(plural, ":") or plural != Macro.underscore(plural) ->
        raise_with_help "Expected the plural argument, #{inspect plural}, to be all lowercase using snake_case convention"

      not Enum.empty?(remaining) ->
        raise_with_help "No arguments expected after the plural argument, #{inspect plural}. All the fields will automatically be created"
      true ->
        {schema, plural}
    end
  end

  @doc false
  def validate_args!(_) do
    raise_with_help "Invalid arguments"
  end

  @doc false
  def raise_with_help(msg) do
    Mix.raise """
    #{msg}

    You can call the mix command with no attributes like below:
      mix av_user_sync.gen.schema

    It'll by default create a schema with the name "Accounts.User"
    and a table with the name "users".

    You can choose to give a custom name to both schema and table
    by writting the command like below:

        mix av_user_sync.gen.schema Shared.User shared_users
    """
  end

  @doc false
  def print_shell_instructions(schema) do
    Mix.shell().info """


    To enable syncing in production, update your configuration in `config/config.exs` with:

      config :av_user_sync,
        otp_app: #{inspect schema.otp_app}
        repo: #{inspect schema.repo},
        schema: #{inspect schema.module}


    Remember to update your repository by running migrations:

        $ mix ecto.migrate
    """
  end

  @doc false
  def valid_schema?(schema) do
    schema =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end
  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)

end
