Router.route '/', ->
  @render 'main'

Router.route '/size/:_width/:_height', ->
  @render 'main',
  	_width:@params._width
  	_height:@params._height