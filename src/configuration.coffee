class Configuration

  ###*
  * Defaults configuration.
  *
  * (Previously defined using option_consume() )
  ###
  DEFAULT_CONFIGURATION_PARAMS ={
    secure: window?.location?.protocol == 'https:'
  }

  @CONFIG_PARAMS = [
    "api_key"
    "api_secret"
    "cdn_subdomain"
    "cloud_name"
    "cname"
    "private_cdn"
    "protocol"
    "resource_type"
    "responsive_width"
    "secure"
    "secure_cdn_subdomain"
    "secure_distribution"
    "shorten"
    "type"
    "url_suffix"
    "use_root_path"
    "version"
  ]

  constructor: (options ={})->
    @configuration = Util.cloneDeep(options)
    Util.defaults( @configuration, DEFAULT_CONFIGURATION_PARAMS)



  ###*
   * Set a new configuration item
   * @param {String} name - the name of the item to set
   * @param value - the value to be set
   *
  ###
  set:(name, value)->
    @configuration[name] = value
    this

  get: (name)->
    @configuration[name]

  merge: (config={})->
    Util.assign(@configuration, Util.cloneDeep(config))
    this

  fromDocument: ->
    meta_elements = document?.querySelectorAll('meta[name^="cloudinary_"]');
    if meta_elements
      for el in meta_elements
        @configuration[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
    this

  fromEnvironment: ->
    cloudinary_url = process?.env?.CLOUDINARY_URL
    if cloudinary_url?
      uri = require('url').parse(cloudinary_url, true)
      cloudinary =
        cloud_name: uri.host,
        api_key: uri.auth and uri.auth.split(":")[0],
        api_secret: uri.auth and uri.auth.split(":")[1],
        private_cdn: uri.pathname?,
        secure_distribution: uri.pathname and uri.pathname.substring(1)
      if uri.query?
        for k, v of uri.query
          cloudinary[k] = v
    this

  ###*
  * Create or modify the Cloudinary client configuration
  *
  * Warning: `config()` returns the actual internal configuration object. modifying it will change the configuration.
  *
  * This is a backward compatibility method. For new code, use get(), merge() etc.
  *
  * @param {Hash|String|true} new_config
  * @param {String} new_value
  * @returns {*} configuration, or value
  *
  ###
  config: (new_config, new_value) ->
    if !@configuration? || new_config == true # REVIEW do we need/want this auto-initialization?
      @fromEnvironment()
      @fromDocument() unless @configuration

    switch
      when new_value != undefined
        @set(new_config, new_value)
        @configuration
      when Util.isString(new_config)
        @get(new_config)
      when Util.isPlainObject(new_config)
        @merge(new_config)
        @configuration
      else
        @configuration

  ###*
   * Returns a copy of the configuration parameters
   * @returns {Object} a key:value collection of the configuration parameters
  ###
  toOptions: ()->
    Util.cloneDeep(@configuration)

unless module?.exports
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary.Configuration = Configuration
