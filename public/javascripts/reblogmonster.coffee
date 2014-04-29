class Reblogmonster
  constructor: ->

  getCookie: ->
    ary = document.cookie.split "; "
    res = []
    for cookie in ary
      spCookie = cookie.split "="
      res[spCookie[0]] = spCookie[1]
    res

do ->
  window.Reblogmonster = new Reblogmonster()
