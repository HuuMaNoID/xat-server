logger = require './utils/logger'
sockets = require './services/sockets'
database = require './services/database'
cmd = require './mixins/cmd-mixin'
config = require 'config'

module.exports =
  class Application
    name: 'Application'

    logger: new logger(this)

    constructor: ->
      @logger.log(@logger.level.INFO, "Starting the server in #{config['env']} at port #{config['port']}...")

      # Handle app events
      @handleEvents()

      # Load plugins
      @loadPlugins()

      # Bootstrap the application
      @bootstrap()

    bootstrap: ->
      self = @

      # Initialize sockets service
      new sockets(config['port']).bind ->
        self.logger.log(self.logger.level.INFO, "Server started and waiting for new connections!")

    handleEvents: ->
      # Registers all basic events of the application
      cmd.regCmd 'application:dispose', @__dispose

    loadPlugins: ->
      for pluginName in config['plugins']
        plugin = require "../plugins/node_modules/#{pluginName}"
        plugin.init()

    __dispose: ->
      # Exit with success code
      process.exit(0)
