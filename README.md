# Augur

<!-- MDOC !-->

Augur deals with sending SMS.

## Installation

Add Augur to your deps:

```elixir
def deps do
  [
    {:augur, "~> 0.1.0"}
  ]
end
```

Initialize `Augur` in your supervision tree with the service config
that you wish to boot with.

For example, if you're using [Vapor](https://github.com/keathley/vapor) you
can do something similar to:

```elixir
def start(_type, _args) do
  children = [
    # ...
    {Augur, augur_config()},
    # ...
  ]

  # ...
end

def augur_config() do
  config = MyApp.Config.sms()

  case config.provider do
    "development" ->
      %Augur.Development{}

    "twilio" ->
      %Augur.Twilio{
        account_sid: config.twilio_account_sid,
        auth_token: config.twilio_auth_token
      }
  end
end
```

## Using Augur

Using Augur is simple. Load the current configuration from `Augur.Config` and then send a text.

An example [Oban Worker](https://github.com/sorentwo/oban) is provided below. You should strongly consider
sending texts only in an out of band worker and not in a web request.

```elixir
defmodule MyApp.SMSWorker do
  use Oban, queue: :sms

  def perform(%Oban.Job{args: text_message}) do
    config = Augur.Config.get()

    from = text_message["from"]
    to = text_message["to"]
    message = text_message["message"]

    case Augur.Service.send_text(config, from, to, message) do
      :ok ->
        :ok

      {:error, exception} ->
        raise exception
    end
  end
end
```
