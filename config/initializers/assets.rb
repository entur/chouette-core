# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( base.css es6_browserified/*.js helpers/*.js filters/*.js)
Rails.application.config.assets.precompile += %w( flags.css )
Rails.application.config.assets.precompile += %w( api.css )
Rails.application.config.assets.precompile += %w( OpenLayers/maps_backgrounds.js )
Rails.application.config.assets.precompile += %w( language_engine/*_flag.png )
