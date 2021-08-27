defmodule Augur.Development do
  @moduledoc """
  Development service for Augur

  Caches all texts being sent from your application in `Augur.Cache`

  ```
  config = %Augur.Development{}
  Augur.Service.send_text(config, "from", "to", "Hello!")
  ```
  """

  alias Augur.Cache
  alias Augur.TextMessage

  defstruct cache: %Augur.Cache{}

  @doc false
  def generate_id() do
    bytes =
      Enum.reduce(1..4, <<>>, fn _, bytes ->
        bytes <> <<Enum.random(0..255)>>
      end)

    Base.encode16(bytes, case: :lower)
  end

  defimpl Augur.Service do
    alias Augur.Development

    def send_text(config, from, to, message) do
      text_message = %TextMessage{
        id: Development.generate_id(),
        from: from,
        to: to,
        message: message,
        sent_at: DateTime.utc_now()
      }

      Cache.cache(config.cache, text_message)

      :ok
    end
  end
end
