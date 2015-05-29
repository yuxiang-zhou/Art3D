
currentlyPressedKeys = {}
z = 300
ycam = 0
ySpeed = 0.05
xloc = 0
yloc = -80
human = null
texture = null
texture1 = null
moving_plane = null
controls = null
clock = new THREE.Clock()
mesh = null

# Sesison Variable
Session.set 'amplitude', 9.0
Session.set 'wavelength', 3.0

n_plane_edge = 100
wave_delta = 0
# Input Handler

handleKeyDown = (event) ->
    # console.log event.keyCode
    currentlyPressedKeys[event.keyCode] = true;

handleKeyUp = (event) ->
    currentlyPressedKeys[event.keyCode] = false;
    if event.keyCode == 49
        human.traverse (child) ->

            if child instanceof THREE.Mesh
                child.material.map = texture

    if event.keyCode == 50
        human.traverse (child) ->

            if child instanceof THREE.Mesh
                child.material.map = texture1


handleKeys = ->
    if currentlyPressedKeys[104]
        # // 8
        ycam += 10

    if currentlyPressedKeys[98]
        # // 2
        ycam -= 10

    if currentlyPressedKeys[87]
        # // w
        z -= 10

    if currentlyPressedKeys[83]
        # // s
        z += 10;
    
    if currentlyPressedKeys[65]
        # // Left cursor key
        ySpeed -= 0.01;
    
    if currentlyPressedKeys[68]
        # // Right cursor key
        ySpeed += 0.01;
    
    if currentlyPressedKeys[38]
        # // Up cursor key
        yloc += 1;
    
    if currentlyPressedKeys[40]
        # // Down cursor key
        yloc -= 1;
    
    if currentlyPressedKeys[37]
        # // Up cursor key
        xloc -= 1;
    
    if currentlyPressedKeys[39]
        # // Down cursor key
        xloc += 1;


feature_wave = (x, y, delta, A=1, W=1) ->
    deg = x + delta
    return A * Math.sin( deg / W )

feature_gaussian = (x, y, delta=0, xmean=0, ymean=0, xstd=1, ystd=1, A=1) ->
    x_gaussian = Math.pow(x-xmean, 2) / (2 * Math.pow(xstd, 2))
    y_gaussian = Math.pow(y-ymean, 2) / (2 * Math.pow(ystd, 2))
    return A * Math.exp (-(x_gaussian + y_gaussian))
    
webGLStart = ->

    container = null
    width = null
    height = null

    camera = null
    scene = null
    renderer = null

    mouseX = 0
    mouseY = 0
    positionX = 0
    positionY = 0

    windowHalfX = width / 2
    windowHalfY = height / 2

    init = ->
        container = document.getElementById 'container'
        width = container.clientWidth
        height = container.clientHeight
        
        # // scene

        scene = new THREE.Scene
        camera = new THREE.PerspectiveCamera 60, width / height, 1, 2000
        camera.position.z = z
        camera.position.y = 100
        camera.position.x = 100
        camera.lookAt(new THREE.Vector3( 0, 0, 0))

        controls = new THREE.FirstPersonControls camera
        controls.movementSpeed = 50
        controls.lookSpeed = 0.1
        controls.lookAt(new THREE.Vector3( 0, 0, 0))
        
        ambient = new THREE.AmbientLight 0x555555
        scene.add ambient 

        directionalLight = new THREE.DirectionalLight 0x999999
        directionalLight.position.set 0, 1, 1
        scene.add directionalLight

        # light = new THREE.PointLight 0xffffff 
        # light.position.copy camera.position
        # scene.add light

        # light = new THREE.PointLight 0xffffff 
        # light.position.copy camera.position
        # light.position.x *= -1
        # light.position.y *= -1
        # light.position.z *= -1
        # scene.add light

        # // texture

        manager = new THREE.LoadingManager
        manager.onProgress = ( item, loaded, total ) ->
            console.log item, loaded, total 

        texture = new THREE.Texture
        texture1 = new THREE.Texture

        onProgress = ( xhr ) ->
            if xhr.lengthComputable
                percentComplete = xhr.loaded / xhr.total * 100
                console.log( Math.round(percentComplete, 2) + '% downloaded' )

        onError = ( xhr ) ->
            console.log 'load error'

        moving_plane = new THREE.PlaneGeometry( 200, 200, n_plane_edge - 1, n_plane_edge - 1)
        moving_plane.applyMatrix( new THREE.Matrix4().makeRotationX( - Math.PI / 2) )
        
        material = new THREE.MeshPhongMaterial( { color: 0xe0dfdb, specular: 0xe0dfdb, metal: true } )

        mesh = new THREE.Mesh( moving_plane, material )
        scene.add mesh 

        renderer = new THREE.WebGLRenderer
        renderer.setPixelRatio window.devicePixelRatio
        renderer.setSize width, height
        container.appendChild renderer.domElement

        # // document.addEventListener( 'mousemove', onDocumentMouseMove, false );
        # document.addEventListener 'keydown', handleKeyDown, false 
        # document.addEventListener 'keyup', handleKeyUp, false 

        window.addEventListener 'resize', onWindowResize, false

    onWindowResize = ->

        width = container.clientWidth
        height = container.clientHeight

        windowHalfX = width / 2
        windowHalfY = height / 2

        camera.aspect = width / height
        camera.updateProjectionMatrix

        renderer.setSize width, height

        controls.handleResize()

    onDocumentMouseMove = ( event ) ->

        mouseX = ( event.clientX - windowHalfX ) / 2
        mouseY = ( event.clientY - windowHalfY ) / 2


    animate = ->

        requestAnimationFrame animate
        handleKeys()
        render()

    render = ->
        delta = clock.getDelta()

        # Get Global Data
        amplitude = Session.get 'amplitude'
        wavelength = Session.get 'wavelength'

        wave_delta += delta * 2

        for i in [0..moving_plane.vertices.length-1]
            x = i % n_plane_edge
            y = Math.floor(i/n_plane_edge)
            moving_plane.vertices[i].y = feature_wave(x,y,wave_delta, amplitude, wavelength)
            moving_plane.vertices[i].y += feature_gaussian(x,y,wave_delta, n_plane_edge / 2, n_plane_edge / 2, 15, 15, amplitude * 5)

        moving_plane.verticesNeedUpdate = true
        moving_plane.normalsNeedUpdate = true

        moving_plane.computeFaceNormals()
        moving_plane.computeVertexNormals()

        controls.update delta
        renderer.render scene, camera

    init()
    animate()


Meteor.startup () ->
    webGLStart()