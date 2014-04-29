express = require 'express'
cookieParser = require 'cookie-parser'
session = require 'express-session'
passport = require 'passport'
TumblrStrategy = require('passport-tumblr').Strategy
coffee = require 'coffee-middleware'
tumblr = require './lib/tumblr'

app = express()

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use cookieParser()
app.use session
  secret: 'secret'
  key: 'sid'
app.use passport.initialize()
app.use passport.session()
app.use coffee
  src: "#{__dirname}/public"
app.use express.static("#{__dirname}/public")

passport.use new TumblrStrategy
  consumerKey: process.env.CONSUMER_KEY
  consumerSecret: process.env.CONSUMER_SECRET
  callbackURL: process.env.CALLBACK_URL
, (token, secret, profile, done)->
  done null,
    username: profile.username
    token: token
    secret: secret

passport.serializeUser (user, done)->
  done null, user

passport.deserializeUser (user, done)->
  done null, user

app.get '/', (req, res)-> res.render 'index'

app.get '/login', passport.authenticate 'tumblr'
app.get '/login/callback', passport.authenticate('tumblr', {failureRedirect: '/login'}), (req, res)->
  res.redirect '/dashboard'

app.get '/dashboard', (req, res)-> res.render 'dashboard'

app.get '/api/dashboard', tumblr.dashboard
app.get '/api/tumblog', tumblr.tumblog
app.get '/api/post/:id/reblog', tumblr.reblog

app.listen process.env.PORT || 3000
