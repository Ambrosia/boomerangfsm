defmodule BoomerangFSM.PlayerTest do
  use ExUnit.Case

  alias BoomerangFSM.Player

  test "two players can be created and be assigned to each other as opponents" do
    assert {:ok, player1} = Player.start_link name: "Player 1"
    assert {:ok, player2} = Player.start_link name: "Player 2", opponent: player1

    Player.add_opponent player1, player2

    assert {:ready_to_throw, %Player{opponent: player2}} = Player.state player1
    assert {:ready_to_throw, %Player{opponent: player1}} = Player.state player2
  end
end
