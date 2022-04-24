defmodule Midterm.DataFeed.Block do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blocks" do
    field :header_hash, :string
    field :received_block_id, :integer
    field :rolled_back, :boolean, default: false
    field :slot, :integer

    timestamps()
  end

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, [:header_hash, :slot, :rolled_back, :received_block_id])
    |> validate_required([:header_hash, :slot, :rolled_back, :received_block_id])
    |> unique_constraint(:slot)
    |> unique_constraint(:header_hash)
  end
end
