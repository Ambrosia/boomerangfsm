defmodule BoomerangFSM.Player do
  @behaviour :gen_fsm

  @derive [Access]
  defstruct name: nil, opponent: nil
  alias __MODULE__

  # Public
  def state(pid) do
    :sys.get_state pid
  end

  # State machine
  def awaiting_opponent(_, state) do
    {:next_state, :awaiting_opponent, state}
  end

  def ready_to_throw(_, state) do
    {:next_state, :ready_to_throw, state}
  end

  # OTP stuff
  def start_link(args) do
    :gen_fsm.start_link(__MODULE__, args, [])
  end

  def init(args) do
    state = %Player{
      name: Keyword.get(args, :name),
      opponent: Keyword.get(args, :opponent)
    }

    case state.opponent do
      nil -> {:ok, :awaiting_opponent, state}
      _   -> {:ok, :ready_to_throw, state}
    end
  end
end
