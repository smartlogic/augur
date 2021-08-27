defprotocol Augur.Service do
  @moduledoc """
  Protocol for defining an SMS service

  Currently defined services:
  - `Augur.Twilio`: send texts via twilio
  - `Augur.Development`: send texts in a development mode, caching texts
  """

  def send_text(_config, from, to, message)
end
