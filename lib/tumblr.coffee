_ = require 'lodash'
async = require 'async'
tumblr = require 'tumblr.js'

createClient = (token, secret)->
  tumblr.createClient
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    token: token
    token_secret: secret

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
  res.send 'TODO'

exports.reblog = (req, res)->
  res.send 'TODO'
