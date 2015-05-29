Template.config.helpers
	amp_val: ->
		return Session.get 'amplitude'

	wave_val: ->
		return Session.get 'wavelength'

Template.config.events
	"input #amplitude": ->
		amplitude = $('#amplitude').val()
		Session.set 'amplitude', amplitude

	"input #wavelength": ->
		wavelength = $('#wavelength').val()
		Session.set 'wavelength', wavelength