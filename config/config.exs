import Config

dir = case System.get_env("DUCK_MNESIA") do
  x when x != nil -> x
  _ -> "#{System.get_env("HOME")}/.config"
end

config :mnesia,
  dir: '#{dir}/DuckTongue/#{node()}'
