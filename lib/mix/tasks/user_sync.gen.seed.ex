defmodule Mix.Tasks.AvUserSync.Gen.Seed do
  use Mix.Task

  @requirements ["app.start"]

  @all_seed_params [
    %{
      id: "77b953f8-3bd6-48c5-9c89-9c5dcf29933e",
      username: "tchalla-blackpanther",
      email: "tchalla@wakanda.com",
      # asyncto_id: user.asyncto_id,
      # display_name: profile.display_name,
      community: "Aspiration",
      phone: "7411296609",
      about: "\"Wakanda Forever!!!\"\r\r\"I never freeze\"\r\r\"Vengeance has consumed you\"",
      profile_picture: "https://files.auroville.org/profiles/77b953f8-3bd6-48c5-9c89-9c5dcf29933e?1668754330"
    },

    %{
      id: "ce584ada-a39a-47b8-ae29-248e20c5a864",
      username: "tony-stark",
      email: "tony@starkindustries.com",
      # asyncto_id: user.asyncto_id,
      # display_name: profile.display_name,
      community: "Aspiration",
      phone: "7411296609",
      about: "\"Genius, billionaire, playboy, philanthropist\"\r\r\"I've successfully privatized world peace\"\r\r\"And I'm iron man....\"",
      profile_picture: "https://files.auroville.org/profiles/ce584ada-a39a-47b8-ae29-248e20c5a864?1669002552"
    },

    %{
      id: "8d74a8d9-75f7-4010-aeae-fee10d928d44",
      username: "wanda-maximoff",
      email: "wanda.maxim@mail.ru",
      # asyncto_id: user.asyncto_id,
      # display_name: profile.display_name,
      community: "Aspiration",
      phone: "9003629169",
      about: "\"You took everything from me\"\r\r\"I was a twin. I had a brother. His name was Pietro\"\r\r\"You break the rules and you become a hero. I do it and I become the enemy. That doesn’t seem fair\"",
      profile_picture: "https://files.auroville.org/profiles/8d74a8d9-75f7-4010-aeae-fee10d928d44?1669003533"
    }
  ]

  def run(argv) do
    # mix av_user_sync.gen.seed

    unless OptionParser.parse(argv, switches: []) == {[], [], []} do
      # If run with arguments. mix av_user_sync.gen.seed will return error
      Mix.raise("mix av_user_sync.gen.seed does not expect any arguments")
    end

    {repo, schema} = get_config()

    check_modules_exists(repo, schema)

    create_test_accounts(repo, schema)

  end

  def get_config do
    otp_app = Application.get_env(:av_user_sync, :otp_app, false)
    unless otp_app, do: raise_with_help("Configuration for otp_app is missing")

    {:ok, _} = Application.ensure_all_started(otp_app)

    repo = Application.get_env(:av_user_sync, :repo)
    schema = Application.get_env(:av_user_sync, :schema)

    cond do
      is_nil(repo) && is_nil(schema) ->
        raise_with_help("Configuration for both repo and schema is missing")

      is_nil(repo) ->
        raise_with_help("Configuration for repo is missing")

      is_nil(schema) ->
        raise_with_help("Configuration for schema is missing")

      true ->
        {repo, schema}
    end
  end

  def check_modules_exists(repo, schema) do
    Code.ensure_compiled!(repo)
    Code.ensure_compiled!(schema)
  end

  defp raise_with_help(msg) do
    Mix.raise """
    #{msg}

    mix av_user_sync.gen.seed expects the below configuration
    in your `config/config.exs`:

      config :av_user_sync,
        repo: YourEctoRepo,
        schema: YourEctoSchma

    """
  end

  @doc """
  Creates all the test accounts with
  """
  def create_test_accounts(repo, schema) do
    Enum.map(@all_seed_params, fn seed_params ->
      schema_struct = struct(schema)
      changeset = Ecto.Changeset.change(schema_struct, seed_params)

      apply(repo, :insert, [changeset, [on_conflict: :replace_all, conflict_target: :id]])
    end)

  end


end
