defmodule Augur.Thread do
  @moduledoc """
  Combine multiple `Augur.TextMessage`s into threads

  Threads contain:
  - A generated ID
  - The messages sorted in chronological descending order
  - Numbers involved
  - A map of numbers to colors for display in the ViewerPlug
  """

  defstruct [:id, :involved, :colors, :messages]

  @colors ["bg-gray-600 text-white", "bg-gray-200"]

  @doc false
  def generate_id() do
    bytes =
      Enum.reduce(1..4, <<>>, fn _, bytes ->
        bytes <> <<Enum.random(0..255)>>
      end)

    Base.encode16(bytes, case: :lower)
  end

  @doc """
  Group text messages into threads
  """
  def group(text_messages) do
    text_messages
    |> Enum.group_by(fn text_message ->
      text_message.thread_id
    end)
    |> Enum.map(fn {thread_id, messages} ->
      messages_to_thread(thread_id, messages)
    end)
  end

  @doc """
  Convert grouped messages into a thread
  """
  def messages_to_thread(thread_id, messages) do
    involved =
      messages
      |> Enum.map(fn message -> message.from end)
      |> Enum.uniq()

    colors =
      Enum.into(Enum.with_index(involved), %{}, fn {number, index} ->
        {number, Enum.at(@colors, index)}
      end)

    messages = Enum.sort_by(messages, fn text_message -> text_message.sent_at end, DateTime)

    %__MODULE__{
      id: thread_id,
      involved: involved,
      colors: colors,
      messages: messages
    }
  end
end
