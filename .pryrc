Pry.editor = 'vim'

Pry.config.prompt = [
  -> (target_self, nest_level, pry) {
    nested = (nest_level == 0) ? '' : ":#{nest_level}"
    "[\e[34m#{pry.input_ring.size}\e[0m] \e[36m\e[1m#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}\e[0m (\e[32m\e[1m#{Pry.view_clip(target_self)}\e[0m)#{nested}> "
  },
  -> (target_self, nest_level, pry) {
    nested = (nest_level == 0) ?  '' : ":#{nest_level}"
    "[\e[34m#{pry.input_ring.size}\e[0m] \e[36m\e[1m#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}\e[0m (\e[32m\e[1m#{Pry.view_clip(target_self)}\e[0m)#{nested}* "
  }
]

{
  'ss' => 'show-source',
  'sm' => 'show-method',
}.each do |from, to|
  Pry::Commands.alias_command(from, to)
end

if defined?(PryByebug)
  {
    'n' => 'next',
    's' => 'step',
    'f' => 'finish',
    'c' => 'continue',
  }.each do |from, to|
    Pry::Commands.alias_command(from, to)
  end
end

def ppp(code)
  puts Pry.Code(code).highlighted
end
