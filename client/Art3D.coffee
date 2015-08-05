Template.config.helpers
	amp_val: ->
		return Session.get 'amplitude'

	wave_val: ->
		return Session.get 'wavelength'

	wave_speed: ->
		return Session.get 'wavespeed'

Template.config.events
	"input #amplitude": ->
		amplitude = $('#amplitude').val()
		Session.set 'amplitude', amplitude

	"input #wavelength": ->
		wavelength = $('#wavelength').val()
		Session.set 'wavelength', wavelength

	"input #wavespeed": ->
		wavespeed = $('#wavespeed').val()
		Session.set 'wavespeed', wavespeed

