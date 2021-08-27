defmodule Augur.TextMessage do
  @moduledoc """
  Development struct for containing information about a sent text
  """

  defstruct [:thread_id, :id, :from, :to, :message, :sent_at]
end
