defmodule BoomerangFSM.PlayerTest do
  use ExUnit.Case, async: true

  alias BoomerangFSM.Player

  test "start_link arguments work correctly" do
    assert {:ok, player1} = Player.start_link name: "Player 1"
    assert {:ok, player2} = Player.start_link name: "Player 2", opponent: player1

    assert {:awaiting_opponent, %Player{name: "Player 1"}} = Player.state player1
    assert {:ready, %Player{opponent: ^player1}} = Player.state player2
  end

  test "players can be assigned to each other" do
    {player1, player2} = create_two_players |> assign_players_to_each_other

    assert {:ready, %Player{opponent: ^player2}} = Player.state player1
    assert {:ready, %Player{opponent: ^player1}} = Player.state player2
  end

  test "player cannot be given a boomerang if they don't have an opponent" do
    {player1, player2} = create_two_players
    Player.give_boomerang player1

    refute {:ready, _} = Player.state player1
  end

  test "a player becomes ready to throw when given a boomerang" do
    {player1, player2} = create_two_players |> assign_players_to_each_other

    Player.give_boomerang player1
    assert {:ready_to_throw, _} = Player.state player1
  end

  test "players become ready to catch after one throws a boomerang" do
    {player1, player2} = create_two_players |> assign_players_to_each_other
    Player.give_boomerang player1
    Player.throw_boomerang player1

    assert {:ready_to_catch, _} = Player.state player1
    assert {:ready_to_catch, _} = Player.state player2
  end

  test "a player's wait to catch time can be changed in any state" do
    {player1, player2} = create_two_players |> assign_players_to_each_other
    Player.set_wait_to_catch_time player1, 1000

    assert {_, %Player{wait_to_catch_time: 1000}} = Player.state player1

    Player.give_boomerang player1
    Player.set_wait_to_catch_time player1, 2000

    assert {_, %Player{wait_to_catch_time: 2000}} = Player.state player1

    Player.throw_boomerang player1
    Player.set_wait_to_catch_time player1, 3000

    assert {_, %Player{wait_to_catch_time: 3000}} = Player.state player1
  end

  defp create_two_players do
    {:ok, player1} = Player.start_link name: "Player 1"
    {:ok, player2} = Player.start_link name: "Player 2"
    {player1, player2}
  end

  defp assign_players_to_each_other({player1, player2}) do
    Player.add_opponent player1, player2
    Player.add_opponent player2, player1
    {player1, player2}
  end
end
