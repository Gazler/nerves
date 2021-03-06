defmodule Mix.Tasks.Firmware.Burn do
  use Mix.Task
  import Mix.Nerves.Utils

  def run(args) do
    Mix.shell.info "Nerves Firmware Burn"
    config = Mix.Project.config
    otp_app = config[:app]
    target = config[:target]

    System.get_env("NERVES_SYSTEM") || raise """
      Environment variable $NERVES_SYSTEM is not set
    """

    System.get_env("NERVES_TOOLCHAIN") || raise """
      Environment variable $NERVES_TOOLCHAIN is not set
    """

    fw = Path.join(File.cwd!, "_images/#{target}/#{otp_app}.fw")
    unless File.exists?(fw) do
      raise "Firmware for target #{target} not found at #{fw} run `mix firmware` to build"
    end

    fwup = "fwup -a -i #{fw} -t complete #{args}"
    fwup =
      case :os.type do
        {_, :darwin} ->
          fwup
        {_, :linux} ->
           ask_pass = System.get_env("SUDO_ASKPASS") || "/usr/bin/ssh-askpass"
           System.put_env("SUDO_ASKPASS", ask_pass)
           "sudo #{fwup}"
        {_, type} ->
          raise "Unable to burn firmware on your host #{inspect type}"
      end
    %{status: 0} = shell(fwup)
  end
end
