defmodule Labryinth.GameChannel do
  use Labyrinth.Web, :channel
  require Logger

  def join("game", _params, socket) do
    {:ok, socket}
  end

  def handle_in("update", %{"x" => gyro_x, "y" => gyro_y}, socket) do
    Logger.debug "Update Gyro X: #{inspect gyro_x} Y: #{inspect gyro_y}"
    File.write "/sys/class/pwm/pwm3/duty_ns", "#{gyro_x}"
    File.write "/sys/class/pwm/pwm4/duty_ns", "#{gyro_y}"
    {:noreply, socket}
  end

end
