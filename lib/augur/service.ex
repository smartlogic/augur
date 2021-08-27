defprotocol Augur.Service do
  @moduledoc """
  Protocol for defining an SMS service

  Currently defined services:
  - `Augur.Twilio`: send texts via twilio
  - `Augur.Development`: send texts in a development mode, caching texts
  """

  @doc """
  Send a text message
  """
  def send_text(config, from, to, message)
end
