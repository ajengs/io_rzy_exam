defmodule IoRzyExam.AccountsTest do
  use IoRzyExam.DataCase

  alias IoRzyExam.{Accounts, Repo}
  alias IoRzyExam.Accounts.Account

  describe "accounts" do
    alias IoRzyExam.Accounts.Model.Account

    import IoRzyExam.AccountsFixtures

    @invalid_attrs %{status: nil, state: nil, account: nil, access_token: nil, routing: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{
        status: true,
        state: "some state",
        account: "some account",
        access_token: "some access_token",
        routing: "some routing"
      }

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.status == true
      assert account.state == "some state"
      assert account.account == "some account"
      assert account.access_token == "some access_token"
      assert account.routing == "some routing"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()

      update_attrs = %{
        status: false,
        state: "some updated state",
        account: "some updated account",
        access_token: "some updated access_token",
        routing: "some updated routing"
      }

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.status == false
      assert account.state == "some updated state"
      assert account.account == "some updated account"
      assert account.access_token == "some updated access_token"
      assert account.routing == "some updated routing"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Repo.get!(Account, account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Account, account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end
end
