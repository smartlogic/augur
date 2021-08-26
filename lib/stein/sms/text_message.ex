defmodule Stein.SMS.TextMessage do
  @moduledoc """
  Development struct for containing information about a sent text
  """

  defstruct [:id, :from, :to, :message, :sent_at]
end
