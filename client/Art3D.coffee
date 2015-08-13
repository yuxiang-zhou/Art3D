Template.config.helpers
    amp_val: ->
        return Session.get 'amplitude'

    wave_val: ->
        return Session.get 'wavelength'

    wave_speed: ->
        return Session.get 'wavespeed'

    isreal: ->
        return if Session.get 'real' then "checked" else ""

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

    "click #isreal": ->
        Session.set 'real', $('#isreal').get(0).checked

Template.code.helpers
    pin_set: ->
        return [1..13]

    gen_code: ->
        code = '<hr>'
        code += '<div>// Code Generate for Arduino</div>'
        code += '<div>float wave_delta = 500;</div>'
        code += '<div>float x = 0;</div>'
        code += '<div>float y = 0;</div>'
        code += '<div>float z = 0;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>float feature_wave(float x, float y, float d, float A, float W)</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;float deg = x + d;</div>'
        code += '<div>&nbsp;&nbsp;return A * sin( deg / W );</div>'
        code += '<div>}</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>float feature_gaussian(float x, float y, float d, float xmean, float ymean, float xstd, float ystd, float A)</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;float x_gaussian = pow(x-xmean, 2) / (2 * pow(xstd, 2));</div>'
        code += '<div>&nbsp;&nbsp;float y_gaussian = pow(y-ymean, 2) / (2 * pow(ystd, 2));</div>'
        code += '<div>&nbsp;&nbsp;return A * exp (-(x_gaussian + y_gaussian));</div>'
        code += '<div>}</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>float feature(float x, float y, float wave_delta, float wavespeed, float amplitude, float wavelength){</div>'
        code += '<div>&nbsp;&nbsp;float z = feature_wave(x, y, wave_delta*wavespeed, amplitude, wavelength);</div>'
        code += '<div>&nbsp;&nbsp;z += feature_gaussian(x, y, wave_delta*2, 0, 0, 60, 60, amplitude * 5);</div>'
        code += '<div>&nbsp;&nbsp;return z;</div>'
        code += '<div>}</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>float range(float v, float l, float h)</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;return fmax(l, fmin(v, h));</div>'
        code += '<div>}</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>void setup()</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;pinMode(' + (Session.get 'EnginePin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;pinMode(' + (Session.get 'DirPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;pinMode(' + (Session.get 'DriverPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;pinMode(' + (Session.get 'HRotPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;pinMode(' + (Session.get 'VRotPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;pinMode(' + (Session.get 'FlapPin') + ',OUTPUT);</div>'
        code += '<div>}</div>'
        code += '<div></div>'
        code += '<div>void loop()</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;float amplitude = 1;</div>'
        code += '<div>&nbsp;&nbsp;float wavelength = 1;</div>'
        code += '<div>&nbsp;&nbsp;float wavespeed = 1;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;float delta = 500;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;float h = feature(x,y,wave_delta,wavespeed,amplitude,wavelength);</div>'
        code += '<div>&nbsp;&nbsp;float dx = feature(x+1, y,wave_delta,wavespeed,amplitude,wavelength) - feature(x-1, y,delta,wavespeed,amplitude,wavelength);</div>'
        code += '<div>&nbsp;&nbsp;float dy = feature(x, y+1,wave_delta,wavespeed,amplitude,wavelength) - feature(x, y-1,delta,wavespeed,amplitude,wavelength);</div>'
        code += '<div>&nbsp;&nbsp;float dz = h - z;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;float motor_speed = dz / delta;</div>'
        code += '<div>&nbsp;&nbsp;float direction = HIGH;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;if(motor_speed < 0)</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;direction = LOW;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;motor_speed = range(abs(motor_speed), 0.00000625, 0.00001);</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;if(abs(delta * motor_speed) > abs(dz)) {</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;motor_speed = 0;</div>'
        code += '<div>&nbsp;&nbsp;} else if(motor_speed > 8) {</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;motor_speed = HIGH;</div>'
        code += '<div>&nbsp;&nbsp;} else {</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;motor_speed = LOW;</div>'
        code += '<div>&nbsp;&nbsp;}</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;float displacement = (motor_speed ? 0.00001 : 0.00000625) * delta;</div>'
        code += '<div>&nbsp;&nbsp;z = direction ? z + displacement : z - displacement;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;digitalWrite(' + (Session.get 'EnginePin') + ',HIGH);</div>'
        code += '<div>&nbsp;&nbsp;digitalWrite(' + (Session.get 'DirPin') + ',direction);</div>'
        code += '<div>&nbsp;&nbsp;digitalWrite(' + (Session.get 'DriverPin') + ',motor_speed);</div>'
        code += '<div>&nbsp;&nbsp;delayMicroseconds(delta);</div>'
        code += '<div>&nbsp;&nbsp;digitalWrite(' + (Session.get 'EnginePin') + ', LOW);</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;wave_delta += delta;</div>'
        code += '<div>}</div>'


        
    
        return code

Template.code.events
    "change #EnginePin": ->
        EnginePin = $('#EnginePin').get(0).value
        Session.set 'EnginePin', EnginePin

    "change #DirPin": ->
        DirPin = $('#DirPin').get(0).value
        Session.set 'DirPin', DirPin

    "change #DriverPin": ->
        DriverPin = $('#DriverPin').get(0).value
        Session.set 'DriverPin', DriverPin

    "change #HRotPin": ->
        HRotPin = $('#HRotPin').get(0).value
        Session.set 'HRotPin', HRotPin

    "change #VRotPin": ->
        VRotPin = $('#VRotPin').get(0).value
        Session.set 'VRotPin', VRotPin

    "change #FlapPin": ->
        FlapPin = $('#FlapPin').get(0).value
        Session.set 'FlapPin', FlapPin