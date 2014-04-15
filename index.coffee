express = require 'express'
cookieParser = require 'cookie-parser'
session = require 'express-session'
passport = require 'passport'
TumblrStrategy = require('passport-tumblr').Strategy

app = express()

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use cookieParser()
app.use session
  secret: 'secret'
  key: 'sid'
app.use passport.initialize()
app.use passport.session()

passport.use new TumblrStrategy
  consumerKey: process.env.CONSUMER_KEY
  consumerSecret: process.env.CONSUMER_SECRET
  callbackURL: process.env.CALLBACK_URL
, (token, secret, profile, done)->
  done null,
    token: token
    username: profile.username

passport.serializeUser (user, done)->
  done null, user

passport.deserializeUser (user, done)->
  done null, user

app.get '/', (req, res)-> res.render 'index'
app.get '/login', passport.authenticate 'tumblr'
app.get '/login/callback', passport.authenticate('tumblr', {failureRedirect: '/login'}), (req, res)->
  console.log req.user
  res.redirect '/'

app.listen process.env.PORT || 3000
