images = require('./images')

module.exports = (app, mw) ->
  aws = app.get('aws_config')

  app.get '/cors', mw.restricted, (req, res, next) ->
    json =
      short_id:   utils.shortId()
      access_key: aws.key
      bucket:     aws.s3.bucket
      policy:     utils.cors_policy()
    json.signature = utils.cors_signature(json.policy)
    res.json(json)

  app.get '/*', (req, res, next) ->
    width   = req.param('w')
    height  = req.param('h')
    width   = 200 unless width? or height?
    res.set('Content-Type', 'image/jpg')
    res.set('Cache-Control', 'public, max-age=31536000')
    res.set('Expires', new Date(Date.now() + 31536000000).toUTCString())
    stream = request.get("http://s3.amazonaws.com/#{aws.s3.bucket}/#{req.params[0]}")
    images[req.param('m') or 'resize'](width, height, stream, res)