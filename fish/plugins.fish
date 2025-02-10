# auto install fundle if not is istalled
if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end

# list of plugins
fundle plugin 'jorgebucaran/fisher'
fundle plugin 'pure-fish/pure'
fundle plugin 'jethrokuan/z'
fundle plugin 'edc/bass'

fundle init
