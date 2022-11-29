defmodule AVUserSync do
  @moduledoc """
  This module contains the core functionality for syncing users.
  """

  alias AVUserSync.{AVAccounts, AVProfile}

  @doc """
  Upserts all users to the given repo and schema
  """
  def upsert_users(repo, schema) do
    av_accounts = list_all_av_accounts()

    Enum.map(av_accounts, fn av_account ->
      user = build_user(av_account, schema)

      apply(repo, :insert, [user, [on_conflict: :replace_all, conflict_target: :id]])
    end)
  end

  @doc """
  Lists all profiles from the AVAccounts repo
  """
  defp list_all_av_accounts() do
    AVAccounts.Repo.all(AVAccounts.User)
  end

  @doc """
  Gets a profile by user from the AVProfile repo
  """
  defp get_profile_by_av_account(%AVAccounts.User{id: id}) do
    AVProfile.Repo.get_by(AVProfile.Profile, auroville_account_id: id)
  end

  @doc """
  Returns a map for inserting into User struct when given a `av_account` and a `schema` to insert into
  """
  defp build_user(av_account, schema) do
    profile = get_profile_by_av_account(av_account)

    fields = %{
      id: av_account.id,
      username: av_account.username,
      email: av_account.email,
      asyncto_id: av_account.asyncto_id
    }

    fields = unless is_nil(profile) do
      {timestamp, _} = NaiveDateTime.to_gregorian_seconds(profile.updated_at)

      profile_picture = case profile.profile_picture do
        nil -> "https://assets.auroville.org.in/profiles/dummy-face.png"
        _ ->  "https://assets.auroville.org.in#{profile.profile_picture}?cache=#{timestamp}"
      end

      additional_fields = %{
        display_name: profile.display_name,
        community: profile.community,
        phone: profile.phone,
        about: profile.about,
        profile_picture: profile_picture
      }

      Map.merge(fields, additional_fields)
    else
      fields
    end

    struct(schema, fields)
  end
end
