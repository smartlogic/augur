defmodule Augur.TextMessage do
  @moduledoc """
  Development struct for containing information about a sent text

  - `thread_id`: Generated ID for the thread the message is in
  - `id`: Generated ID for the message itself
  - `from`: The phone number the message is sent from
  - `to`: The phone number the message is sent to
  - `message`: Message that is being sent
  - `sent_at`: Timestamp of when the text message was sent
  """

  defstruct [:thread_id, :id, :from, :to, :message, :sent_at]
end
