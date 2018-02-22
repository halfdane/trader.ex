ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Trader.Repo, :manual)

{:ok, files} = File.ls("./test/test_data")

Enum.each(files, fn file ->
  Code.require_file("test_data/#{file}", __DIR__)
end)
