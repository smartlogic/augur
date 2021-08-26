defprotocol Stein.SMS.Service do
  @moduledoc """
  Protocol for defining an SMS service

  Currently defined services:
  - `Stein.SMS.Twilio`: send texts via twilio
  - `Stein.SMS.Development`: send texts in a development mode, caching texts
  """

  def send_text(_config, from, to, message)
end
