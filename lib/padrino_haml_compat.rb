# Compatibility shim for padrino-helpers >= 0.16 on Haml >= 6.
#
# padrino-helpers picks its Haml output handler once, when it is first required.
# At that point Padrino::Rendering::HamlTemplate is the preferred Tilt engine for
# ".haml", so it registers HamlHandler. HamlHandler calls `template.block_is_haml?`
# and `template.capture_haml`, both removed from Haml::Helpers in Haml 6. Middleman
# loads Haml and Padrino in that order and runs no Padrino rendering app, so the
# handler can never match: falling through to the caller's block (what
# HamlitHandler does) is the correct behaviour.
#
# Loaded from config.rb, i.e. after middleman has required padrino-helpers.
module PadrinoHamlCompat
  def engine_matches?(_block)
    false
  end
end

Padrino::Helpers::OutputHelpers::HamlHandler.prepend(PadrinoHamlCompat)
