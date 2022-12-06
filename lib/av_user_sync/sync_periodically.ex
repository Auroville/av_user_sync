defmodule AVUserSync.SyncPeriodically do
  @moduledoc """
  Genserver for syncing all users periodically from two source repos.

  This needs to be added into your application's supervision tree:

    def start(_type, _args) do
      children = [
        ...
        AVUserSync.SyncPeriodically
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]
      Supervisor.start_link(children, opts)
    end

  For SyncPeriodically to be run, in your `config/config.exs`:

    config :av_user_sync,
      repo: YourEctoRepo,
      schema: YourEctoSchma

  You also need to have configured repo of `AVUserSync.AVAccounts.Repo`
  and `AVUserSync.AVProfile.Repo` like how you would configure any repo.

  If the configurations are not found, then the SyncPeriodically won't
  run and throw a warning saying configurations are not found

  The default interval of syncing is 10 minutes. Additionaly, you can
  also configure the interval timer. You may find an example configuring
  the timer to be 5 minutes:

    config :av_user_sync,
      interval_sync_timer: 300000 # Millisecond value


  """

  use GenServer
  require Logger

  @default_timer 10 * 60 * 1000

  # Client APIs
  def start_link(_opts) do
    timer = Application.get_env(:av_user_sync, :sync_timer, false) || @default_timer

    repo = Application.get_env(:av_user_sync, :repo)
    schema = Application.get_env(:av_user_sync, :schema)

    source_repos_configured? = Application.get_env(:av_user_sync, AVUserSync.AVProfile.Repo, false) && Application.get_env(:av_user_sync, AVUserSync.AVAccounts.Repo, false)

    state = %{timer: timer, repo_to_sync: repo, schema_to_sync: schema, source_repos_configured?: source_repos_configured?}

    GenServer.start_link(__MODULE__, state)
  end

  # Server callbacks
  def init(%{source_repos_configured?: false}) do
    Logger.warn("Source repos not configured")
    :ignore
  end

  def init(%{repo_to_sync: nil}) do
    Logger.warn("Configuration missing for either repo or schema for syncing")
    :ignore
  end

  def init(%{schema_to_sync: nil}) do
    Logger.warn("Configuration missing for either repo or schema for syncing")
    :ignore
  end

  def init(%{timer: timer, repo: repo, schema: schema} = state) do
    Process.send_after(self(), :upsert_users, timer)

    AVUserSync.upsert_users(repo, schema)

    {:ok, state}
  end

  def handle_info(:upsert_users, %{timer: timer, repo: repo, schema: schema}) do
    Process.send_after(self(), :upsert_users, timer)

    AVUserSync.upsert_users(repo, schema)
  end
end
