defmodule Mix.Tasks.AvUserSync.Gen.Schema do
  @moduledoc """
  Generates schema and migration for user

  You can call the mix command with no attributes like below:

      $ mix av_user_sync.gen.schema

  It'll by default create a schema with the name "Accounts.User"
  and a table with the name "users".

  The generated schema and table will have all the fields listed below:
  1. `id` - Primay ID (binary)
  1. `username` - String
  1. `email` - String
  1. `asyncto_id` - String
  1. `display_name` - String
  1. `community` - String
  1. `phone` - String
  1. `about` - Text
  1. `profile_picture` - String

  You can choose to give a custom name to both schema and table
  by writting the command like below:

      $ mix av_user_sync.gen.schema Shared.User shared_users

  Make sure you give valid schema and table name.
  """
  @shortdoc "Generates schema and migration for user"

  use Mix.Task

  alias Mix.AVUserSync.Schema


  @switches []


  @doc false
  def run(argv) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix av_user_sync.gen.schema must be invoked from within your *_web application root directory")
    end

    schema = build(argv)

    Schema.prompt_for_conflict(schema)

    schema
    |> copy_new_files()
    |> print_shell_instructions()
  end

  @doc false
  def build(argv) do
    {_, parsed, _} = OptionParser.parse(argv, switches: @switches)

    {schema_name, plural} = validate_args!(parsed)


    Schema.new(schema_name, plural, [])
    # TODO: Give optional arguments given from shell to the function
    # The reason we're giving an empty list is because the actual function is not ready to use opts and we need to design a whole new workflow for that
  end

  @doc false
  def copy_new_files(%{context_app: ctx_app} = schema) do
    priv_directory = :code.priv_dir(:av_user_sync) |> String.Chars.to_string()

    schema_source = priv_directory <> "/templates/user_schema.ex"
    migration_source = priv_directory <> "/templates/user_migration.exs"

    schema_source = if File.exists?(schema_source), do: schema_source || raise "could not find the #{schema_source}"
    migration_source = if File.exists?(migration_source), do: migration_source || raise "could not find the #{migration_source}"

    schema_target = schema.file
    Mix.Generator.create_file(schema_target, EEx.eval_file(schema_source, schema: schema))

    timestamp = Schema.timestamp()
    migration_target = Mix.AVUserSync.context_app_path(ctx_app, "priv/repo/migrations/#{timestamp}_create_#{schema.table}.exs")
    Mix.Generator.create_file(migration_target, EEx.eval_file(migration_source, schema: schema))

    schema
  end

  @doc false
  def validate_args!([]) do
    {"Accounts.User", "users"}
  end

  @doc false
  def validate_args!([schema, plural | remaining] = _args) do
    cond do
      not Schema.valid_schema?(schema) ->
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

end
