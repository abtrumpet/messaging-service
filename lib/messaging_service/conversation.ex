defmodule MessagingService.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :participants_key, :string
    field :participants, {:array, :string}

    has_many :messages, MessagingService.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:participants_key, :participants])
    |> validate_required([:participants_key, :participants])
    |> unique_constraint(:participants_key)
  end

  @doc """
  Generates a normalized participants key from a list of participant identifiers.
  This ensures that conversations between the same participants are grouped together
  regardless of the order of from/to fields.
  """
  def generate_participants_key(participant1, participant2) do
    [participant1, participant2]
    |> Enum.map(&normalize_participant/1)
    |> Enum.sort()
    |> Enum.join(":")
  end

  defp normalize_participant(participant) do
    participant
    |> String.downcase()
    |> String.trim()
  end
end
