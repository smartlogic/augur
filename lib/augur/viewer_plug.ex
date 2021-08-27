defmodule Augur.ViewerPlug do
  @moduledoc """
  View cached messages in a familiar interface

  Forward requests to this plug from your router:

  ```
  if Mix.env() == :dev do
    forward("/sms/sent", Augur.ViewerPlug)
  end
  ```
  """

  use Plug.Router
  require EEx

  alias Augur.Config
  alias Augur.Cache

  index_template = Path.join(__DIR__, "templates/index.html.eex")
  EEx.function_from_file(:defp, :index, index_template, [:assigns])

  thread_template = Path.join(__DIR__, "templates/thread.html.eex")
  EEx.function_from_file(:defp, :thread, thread_template, [:assigns])

  plug(:match)
  plug(:dispatch)

  get("/") do
    config = Config.get()
    threads = Cache.threads(config.cache)

    assigns = %{
      conn: conn,
      base_path: base_path(conn),
      threads: threads
    }

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> send_resp(200, index(assigns))
  end

  get("/threads/:id") do
    config = Config.get()
    thread = Cache.thread(config.cache, conn.params["id"])

    assigns = %{
      conn: conn,
      base_path: base_path(conn),
      thread: thread
    }

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> send_resp(200, thread(assigns))
  end

  defp base_path(%{script_name: script_name}) do
    "/" <> Enum.join(script_name, "/")
  end

  @doc false
  def format_phone_number(phone_number) do
    regex = ~r/^(\+1)?(?<area_code>\d{3})(?<exchange_code>\d{3})(?<line_number>\d{4})/
    captures = Regex.named_captures(regex, phone_number)
    "(#{captures["area_code"]}) #{captures["exchange_code"]}-#{captures["line_number"]}"
  end
end
