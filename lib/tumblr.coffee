tumblr = require 'tumblr.js'

createClient = (token, secret)->
  tumblr.createClient
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    token: token
    token_secret: secret

exports.dashboard = (req, res)->
  client = createClient req.session.passport.user.token, req.session.passport.user.secret
  client.dashboard {}, (err, data)->
    res.send JSON.stringify(data.posts)
