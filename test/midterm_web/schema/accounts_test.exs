defmodule MidtermWeb.Schema.AccountsTest do
  use MidtermWeb.ConnCase, async: true

  import Midterm.AccountsFixtures
  alias Midterm.Accounts

  @account_by_address_hash_doc """
  query Account($address_hash: String!) {
    account(address_hash: $address_hash) {
      id
      address_hash
      alias
      credits
      email
      push_over_key
      sms
      status
    }
  }
  """

  describe "@account" do
    test "fetches an account with valid api_key" do
      assert api_access = api_access_fixture()
      assert {:ok, account} = Accounts.get_account(%{api_access_id: api_access.id})

      conn = build_conn() |> auth_account(api_access)

      conn =
        post conn, "/api",
          query: @account_by_address_hash_doc,
          variables: %{"address_hash" => account.address_hash}

      assert json_response(conn, 200) == %{
               "data" => %{
                 "account" => %{
                   "address_hash" => account.address_hash,
                   "alias" => account.alias,
                   "credits" => account.credits,
                   "email" => account.email,
                   "id" => account.id,
                   "push_over_key" => account.push_over_key,
                   "sms" => account.sms,
                   "status" => Atom.to_string(account.status)
                 }
               }
             }
    end

    test "does not fetch an account without valid api_key" do
      assert api_access = api_access_fixture()
      assert {:ok, account} = Accounts.get_account(%{api_access_id: api_access.id})

      conn = build_conn()

      conn =
        post conn, "/api",
          query: @account_by_address_hash_doc,
          variables: %{"address_hash" => account.address_hash}

      assert %{
               "errors" => errors
             } = json_response(conn, 200)

      error_messages = errors |> Enum.map(&Map.get(&1, "message")) |> Enum.join()
      assert error_messages =~ "unauthorized"
    end
  end

  defp auth_account(conn, %{api_key: api_key}) do
    put_req_header(conn, "authorization", "Bearer #{api_key}")
  end
end
