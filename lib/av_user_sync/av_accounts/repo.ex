defmodule AVUserSync.AVAccounts.Repo do
  use Ecto.Repo,
    otp_app: :av_user_sync,
    adapter: Ecto.Adapters.Postgres
end
