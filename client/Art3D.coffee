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
        code += '<div>//&nbsp;Time&nbsp;Laps</div>'
        code += '<div>float&nbsp;wave_delta&nbsp;=&nbsp;0;</div>'
        code += '<div></div>'
        code += '<div>//&nbsp;Initial&nbsp;Position</div>'
        code += '<div>float&nbsp;x&nbsp;=&nbsp;0;</div>'
        code += '<div>float&nbsp;y&nbsp;=&nbsp;0;</div>'
        code += '<div>float&nbsp;z&nbsp;=&nbsp;0;</div>'
        code += '<div></div>'
        code += '<div>//&nbsp;runing&nbsp;at&nbsp;10&nbsp;FPS</div>'
        code += '<div>float&nbsp;delta&nbsp;=&nbsp;100000;</div>'
        code += '<div></div>'
        code += '<div>//&nbsp;speed&nbsp;period</div>'
        code += '<div>float&nbsp;speed_max&nbsp;=&nbsp;500;</div>'
        code += '<div>float&nbsp;speed_min&nbsp;=&nbsp;800;</div>'
        code += '<div>float&nbsp;step_size&nbsp;=&nbsp;0.05;</div>'
        code += '<div></div>'
        code += '<div>//&nbsp;Feature&nbsp;Functions</div>'
        code += '<div>float&nbsp;feature_wave(float&nbsp;x,&nbsp;float&nbsp;y,&nbsp;float&nbsp;d,&nbsp;float&nbsp;A,&nbsp;float&nbsp;W)</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;deg&nbsp;=&nbsp;x&nbsp;+&nbsp;d;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;A&nbsp;*&nbsp;sin(&nbsp;deg&nbsp;/&nbsp;W&nbsp;);</div>'
        code += '<div>}</div>'
        code += '<div></div>'
        code += '<div>float&nbsp;feature_gaussian(float&nbsp;x,&nbsp;float&nbsp;y,&nbsp;float&nbsp;d,&nbsp;float&nbsp;xmean,&nbsp;float&nbsp;ymean,&nbsp;float&nbsp;xstd,&nbsp;float&nbsp;ystd,&nbsp;float&nbsp;A)</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;x_gaussian&nbsp;=&nbsp;pow(x-xmean,&nbsp;2)&nbsp;/&nbsp;(2&nbsp;*&nbsp;pow(xstd,&nbsp;2));</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;y_gaussian&nbsp;=&nbsp;pow(y-ymean,&nbsp;2)&nbsp;/&nbsp;(2&nbsp;*&nbsp;pow(ystd,&nbsp;2));</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;A&nbsp;*&nbsp;exp&nbsp;(-(x_gaussian&nbsp;+&nbsp;y_gaussian));</div>'
        code += '<div>}</div>'
        code += '<div></div>'
        code += '<div>float&nbsp;feature(float&nbsp;x,&nbsp;float&nbsp;y,&nbsp;float&nbsp;wave_delta,&nbsp;float&nbsp;wavespeed,&nbsp;float&nbsp;amplitude,&nbsp;float&nbsp;wavelength){</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;z&nbsp;=&nbsp;feature_wave(x,&nbsp;y,&nbsp;wave_delta*wavespeed,&nbsp;amplitude,&nbsp;wavelength);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;z&nbsp;+=&nbsp;feature_gaussian(x,&nbsp;y,&nbsp;wave_delta*2,&nbsp;0,&nbsp;0,&nbsp;60,&nbsp;60,&nbsp;amplitude&nbsp;*&nbsp;5);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;z&nbsp;-&nbsp;35;</div>'
        code += '<div>}</div>'
        code += '<div></div>'
        code += '<div>//&nbsp;Helper</div>'
        code += '<div>float&nbsp;range(float&nbsp;v,&nbsp;float&nbsp;l,&nbsp;float&nbsp;h)</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;fmax(l,&nbsp;fmin(v,&nbsp;h));</div>'
        code += '<div>}</div>'
        code += '<div></div>'
        code += '<div>//&nbsp;Main</div>'
        code += '<div>void&nbsp;setup()</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;pinMode(' + (Session.get 'EnginePin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;pinMode(' + (Session.get 'DirPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;pinMode(' + (Session.get 'DriverPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;pinMode(' + (Session.get 'HRotPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;pinMode(' + (Session.get 'VRotPin') + ',OUTPUT);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;pinMode(' + (Session.get 'FlapPin') + ',OUTPUT);</div>'
        code += '<div>}</div>'
        code += '<div></div>'
        code += '<div>void&nbsp;loop()</div>'
        code += '<div>{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;TODO:&nbsp;Readings&nbsp;from&nbsp;sensor</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float amplitude = '+(Session.get 'amplitude')+';</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float wavelength = '+(Session.get 'wavelength')+';</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float wavespeed = '+(Session.get 'wavespeed')+';</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;target</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;h&nbsp;=&nbsp;feature(x,y,wave_delta,wavespeed,amplitude,wavelength);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;dx&nbsp;=&nbsp;feature(x+1,&nbsp;y,wave_delta,wavespeed,amplitude,wavelength)&nbsp;-&nbsp;feature(x-1,&nbsp;y,wave_delta,wavespeed,amplitude,wavelength);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;dy&nbsp;=&nbsp;feature(x,&nbsp;y+1,wave_delta,wavespeed,amplitude,wavelength)&nbsp;-&nbsp;feature(x,&nbsp;y-1,wave_delta,wavespeed,amplitude,wavelength);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;dz&nbsp;=&nbsp;h&nbsp;-&nbsp;z;</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;set&nbsp;default&nbsp;value</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;motor_speed&nbsp;=&nbsp;step_size&nbsp;/&nbsp;(dz&nbsp;*&nbsp;10&nbsp;/&nbsp;delta)&nbsp;/&nbsp;2.0;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;direction&nbsp;=&nbsp;HIGH;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;displacement&nbsp;=&nbsp;0;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;nPulse&nbsp;=&nbsp;0;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;float&nbsp;engine&nbsp;=&nbsp;HIGH;</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;set&nbsp;direction</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;if(motor_speed&nbsp;<&nbsp;0)&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;direction&nbsp;=&nbsp;LOW;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;set&nbsp;and&nbsp;limit&nbsp;step&nbsp;period&nbsp;between&nbsp;(500,&nbsp;800)</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;motor_speed&nbsp;=&nbsp;range(abs(motor_speed),&nbsp;speed_max,&nbsp;speed_min);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;calculate&nbsp;number&nbsp;of&nbsp;pulses&nbsp;needed&nbsp;for&nbsp;1&nbsp;frame</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;nPulse&nbsp;=&nbsp;floor(delta&nbsp;/&nbsp;2.0&nbsp;/&nbsp;motor_speed);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;calculate&nbsp;expected&nbsp;displacement</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;displacement&nbsp;=&nbsp;nPulse&nbsp;*&nbsp;step_size;&nbsp;//&nbsp;unit&nbsp;mm</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;no&nbsp;movement&nbsp;for&nbsp;tiny&nbsp;displacement</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;if(displacement&nbsp;>&nbsp;abs(dz)&nbsp;*&nbsp;10)&nbsp;{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;engine&nbsp;=&nbsp;LOW;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;displacement&nbsp;=&nbsp;0;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;}</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;set&nbsp;unit&nbsp;of&nbsp;displacement&nbsp;to&nbsp;cm</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;displacement&nbsp;*=&nbsp;0.1;</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;update&nbsp;new&nbsp;finishing&nbsp;z-index</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;z&nbsp;=&nbsp;direction&nbsp;?&nbsp;z&nbsp;+&nbsp;displacement&nbsp;:&nbsp;z&nbsp;-&nbsp;displacement;&nbsp;</div>'
        code += '<div></div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;Operating</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;Set&nbsp;Direction</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;digitalWrite(' + (Session.get 'DirPin') + ',direction);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;delayMicroseconds(10000);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;Start&nbsp;engine</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;digitalWrite(' + (Session.get 'EnginePin') + ',engine);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;Sending&nbsp;Pulses</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;for(int&nbsp;i&nbsp;=&nbsp;0;&nbsp;i&nbsp;<&nbsp;nPulse;&nbsp;++i)&nbsp;{</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;digitalWrite(' + (Session.get 'DriverPin') + ',HIGH);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;delayMicroseconds(motor_speed);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;digitalWrite(' + (Session.get 'DriverPin') + ',LOW);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;delayMicroseconds(motor_speed);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;}</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;Stop&nbsp;Engine</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;digitalWrite(' + (Session.get 'EnginePin') + ',&nbsp;LOW);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;Filling&nbsp;gap&nbsp;with&nbsp;delay&nbsp;to&nbsp;match&nbsp;frame&nbsp;size</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;delayMicroseconds(delta&nbsp;-&nbsp;nPulse&nbsp;*&nbsp;motor_speed&nbsp;*&nbsp;2);</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;</div>'
        code += '<div>&nbsp;&nbsp;&nbsp;&nbsp;wave_delta&nbsp;+=&nbsp;delta&nbsp;/&nbsp;1000000;</div>'
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