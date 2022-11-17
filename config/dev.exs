import Config

config :av_user_sync, AVUserSync.AVProfile.Repo,
  database: "av_profile_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :av_user_sync, AVUserSync.AVAccounts.Repo,
  database: "av_accounts_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"


config :av_user_sync,
  ecto_repos: [AVUserSync.AVProfile.Repo, AVUserSync.AVAccounts.Repo]
