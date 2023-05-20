defmodule Sender.Repo do
  use Ecto.Repo,
    otp_app: :sender,
    adapter: Ecto.Adapters.Postgres
end
