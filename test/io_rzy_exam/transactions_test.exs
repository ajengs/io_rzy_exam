defmodule IoRzyExam.TransactionsTest do
  use IoRzyExam.DataCase

  alias IoRzyExam.{Transactions, Repo}
  alias IoRzyExam.Transactions.Transaction

  import IoRzyExam.TransactionsFixtures

  describe "transactions" do
    @invalid_attrs %{time: nil, account: nil, company: nil, amount: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Transactions.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{
        time: ~N[2024-06-22 17:15:00],
        account: "some account",
        company: "some company",
        amount: "120.5"
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.time == ~N[2024-06-22 17:15:00]
      assert transaction.account == "some account"
      assert transaction.company == "some company"
      assert Decimal.equal?(transaction.amount, Decimal.new("120.5"))
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()

      update_attrs = %{
        time: ~N[2024-06-23 17:15:00],
        account: "some updated account",
        company: "some updated company",
        amount: "456.7"
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.time == ~N[2024-06-23 17:15:00]
      assert transaction.account == "some updated account"
      assert transaction.company == "some updated company"
      assert Decimal.equal?(transaction.amount, Decimal.new("456.7"))
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert transaction == Repo.get!(Transaction, transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Transaction, transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
