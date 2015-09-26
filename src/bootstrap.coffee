startTime = Date.now()

pkg = require '../package'
server = require './services/server'
database = require './services/database'

{EventEmitter} = require 'events'
_ = require 'underscore'

module.exports =
class Application
  _.extend @prototype, EventEmitter.prototype

  ###
  Section: Properties
  ###
  logger: null
  config: null

  ###
  Section: Construction
  ###
  constructor: ->
    global.Application = this

    @config = require "../config/default"
    @logger = new (require "./utils/logger")(Application)
    
    @logger.log @logger.level.DEBUG, "You are running #{pkg.name} #{pkg.version}"
    @logger.log @logger.level.INFO, "Starting the server in #{@config.env} at port #{@config.port}..."

    # Handle app events
    @handleEvents()

    # Load plugins
    @loadPlugins()

    # Bootstrap the application
    @bootstrap()

  ###
  Section: Private
  ###
  bootstrap: ->
    # TODO: First ping database and then initialize the server
    # Initialize database service
    @logger.log @logger.level.INFO, "Checking connectivity with database..."
    database.acquire (err, db) -> database.release db

    # Initialize server service
    server = new server(@config.port)
    server.bind =>
      @logger.log @logger.level.INFO, "Server started in #{Date.now() - startTime}ms"

  handleEvents: ->
    # Register all application events
    @on 'application:dispose', @dispose

  loadPlugins: ->
    return

    # TODO: Plugin loader / handler
    # plugins = pkg.packageDependencies

  dispose: ->
    # Exit with success code
    process.exit(0)
