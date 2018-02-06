use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"5tE4]UNs[9G,yF!?;s,;csijq4E``|Ey*9&eeqIJmf^mVv!=0apR],!*fWhCUeJy"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"4:w&~o@qp$Kix}RHN7Q)5%U@E)D./Sw(9.~3C8j5:<A11;NTX0ER&JmhO0/,)1rt"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :trader do
  set version: current_version(:trader)
end
