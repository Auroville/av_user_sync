defmodule AVUserSync.SyncPeriodically do
  use GenServer

  @default_timer 10 * 60 * 1000

  # Client APIs
  def start_link(_opts) do
    timer = Application.get_env(:av_user_sync, :sync_timer, false) || @default_timer

    GenServer.start_link(__MODULE__, %{timer: timer})
  end

  # Server callbacks
  def init(state) do
    Process.send_after(self(), :upsert_users, state.timer)

    AVUserSync.upsert_users()

    {:ok, state}
  end

  def handle_info(:upsert_users, state) do
    Process.send_after(self(), :upsert_users, state.timer)

    AVUserSync.upsert_users()
  end


end
