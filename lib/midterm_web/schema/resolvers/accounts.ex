defmodule MidtermWeb.Resolvers.Accounts do
  alias Midterm.Accounts

  def get_account_by_address_hash(_parent, params, %{context: context}) do
    case context do
      %{current_api_access: %{account: account}}
      when account.address_hash === params.address_hash ->
        Accounts.get_account_by_params(params)

      _ ->
        {:error, "unauthorized"}
    end
  end

  def create_watched_address(_parent, params, %{
        context: context
      }) do
    case context do
      %{current_api_access: %{account: account}}
      when account.address_hash === params.account_address_hash ->
        Accounts.create_watched_address_and_account_watched_address(%{
          account_id: account.id,
          address_hash: params.watched_address_hash,
          name: params["name"] || nil
        })

      _ ->
        {:error, "unauthorized"}
    end
  end

  def reset_api_key(_parent, params, %{
        context: context
      }) do
    case context do
      %{current_api_access: %{account: account}}
      when account.address_hash === params.account_address_hash ->
        Accounts.update_api_key(account.id)

      _ ->
        {:error, "unauthorized"}
    end
  end

  def update_notification_preferences(
        _parent,
        params,
        %{
          context: context
        }
      ) do
    case context do
      %{current_api_access: %{account: account}}
      when account.address_hash === params.account_address_hash ->
        case Accounts.find_notification_preference_by_account_id_and_watched_address_hash(
               account.id,
               params.watched_address_hash
             ) do
          {:ok, notification_preference} ->
            Accounts.update_notification_preference(
              notification_preference,
              params.notification_preferences
            )

          error ->
            error
        end

      _ ->
        {:error, "unauthorized"}
    end
  end
end
