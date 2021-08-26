defmodule Stein.SMS.Twilio do
  @moduledoc """
  Twilio service for Stein.SMS

  Sends texts via Twilio messaging API

  Configuration required:
  - `account_sid`: Find this on the Twilio Dashboard
  - `auth_token`: Find this on the Twilio Dashboard
  """

  @enforce_keys [:account_sid, :auth_token]
  defstruct [:account_sid, :auth_token, cache: %Stein.SMS.Cache{}, finch_name: Stein.SMS.Twilio]

  defmodule Exception do
    defexception [:body, :code, :reason, :status]

    def message(struct) do
      """
      Twilio failed an API request

      Error Code: #{struct.code} - #{struct.reason}

      Status: #{struct.status}
      Body:
      #{inspect(struct.body, pretty: true)}
      """
    end
  end

  defimpl Stein.SMS.Service do
    alias Stein.SMS.Twilio

    @twilio_base_url "https://api.twilio.com/2010-04-01/Accounts/"

    def send_text(config, from, to, message) do
      basic_auth = "#{config.account_sid}:#{config.auth_token}" |> Base.encode64()
      api_url = "#{@twilio_base_url}#{config.account_sid}/Messages.json"

      req_headers = [
        {"Authorization", "Basic #{basic_auth}"},
        {"Content-Type", "application/x-www-form-urlencoded"}
      ]

      req_body =
        URI.encode_query(%{
          "Body" => message,
          "From" => from,
          "To" => to
        })

      request = Finch.build(:post, api_url, req_headers, req_body)

      case Finch.request(request, config.finch_name) do
        {:ok, %{status: 201}} ->
          :ok

        {:ok, %{body: body, status: 400}} ->
          body = Jason.decode!(body)

          exception = %Twilio.Exception{
            code: body["code"],
            body: body,
            reason: body["message"],
            status: 400
          }

          {:error, exception}

        {:ok, %{body: body, status: status}} ->
          body = Jason.decode!(body)

          exception = %Twilio.Exception{
            body: body,
            reason: "Unknown error",
            status: status
          }

          {:error, exception}
      end
    end
  end
end
