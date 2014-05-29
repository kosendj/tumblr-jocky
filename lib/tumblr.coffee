_ = require 'lodash'
async = require 'async'
tumblr = require 'tumblr.js'

createClient = (token, secret)->
  tumblr.createClient
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    token: token
    token_secret: secret

createTJbu = ->
  tumblr.createClient
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    token: process.env.TJBU_TOKEN
    token_secret: process.env.TJBU_SECRET

exports.dashboard = (req, res)->
  client = createClient req.session.passport.user.token, req.session.passport.user.secret
  if req.query.init is "true"
    async.map [0..4], (num, callback)->
      client.dashboard
        offset: num * 20
      , (err, data)->
        callback err, data.posts
    , (err, results)->
      res.send JSON.stringify(_.flatten(results))
  else
    client.dashboard
      since_id: req.query.since_id
    , (err, data)->
      res.send JSON.stringify(data.posts)

exports.tumblog = (req, res)->
  client = createClient req.session.passport.user.token, req.session.passport.user.secret
  client.posts req.query.name,
    type: 'photo'
    offset: req.query.offset
  , (err, data)->
    res.send JSON.stringify(data.posts)

exports.reblog = (req, res)->
  client = createTJbu()
  client.reblog "tjbu",
    id: req.params.id
    reblog_key: req.body.reblogKey
  , (err)->
    res.send JSON.stringify({status: 'success'})
