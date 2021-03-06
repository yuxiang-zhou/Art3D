
currentlyPressedKeys = {}

camz = 160
camy = 100
camx = 160

controls = null
clock = new THREE.Clock()

mesh = null
models = null
moving_plane = null

angle = 0

nWidth = 20 
nHight = 20

edgeWidth = 20

# Sesison Variable
Session.set 'amplitude', 8.9
Session.set 'wavelength', 19.6
Session.set 'wavespeed', 5
Session.set 'wireframe', false
Session.set 'real', true
Session.set 'EnginePin', 1
Session.set 'DirPin', 1
Session.set 'DriverPin', 1
Session.set 'HRotPin', 1
Session.set 'VRotPin', 1
Session.set 'FlapPin', 1

n_plane_edge = 100
wave_delta = 0

# features
feature_wave = (x, y, delta, A=1, W=1) ->
    deg = x + delta
    return A * Math.sin( deg / W )

feature_gaussian = (x, y, delta=0, xmean=0, ymean=0, xstd=1, ystd=1, A=1) ->
    x_gaussian = Math.pow(x-xmean, 2) / (2 * Math.pow(xstd, 2))
    y_gaussian = Math.pow(y-ymean, 2) / (2 * Math.pow(ystd, 2))
    return A * Math.exp (-(x_gaussian + y_gaussian))

# Initialise Models
generateModels = (nSize, edgeSize) ->
    material = new THREE.MeshPhongMaterial
        color: 0xe0dfdb,
        specular: 0xe0dfdb,
        metal: true,
        wireframe: Session.get 'wireframe'

    ms = []
    for i in [0..nSize-1]
        ms.push(new @TriDM(edgeSize, material))

    Session.set 'meterial', material
    return ms

addModelScene = (ms, scene) ->
    for m in ms
        scene.add m.meshs

setGrid = (ms, rowSize) ->
    indexToCood = (ind, m) ->
        [row, col] = [Math.floor(ind / rowSize), ind % rowSize]
        [row_d, row_r] = [Math.floor(row / 2), row % 2]
        [col_d, col_r] = [Math.floor(col / 2), col % 2]

        x = col * m.c
        y = 6*row_d+4*row_r - (row_r * 2 - 1)*col_r
        y *= m.a

        return {x:x, y:y, cr:col_r, rr:row_r}

    mid_ind = ms.length / 2
    mean_coord_l = indexToCood(mid_ind + 1, ms[0])
    mean_coord_r = indexToCood(mid_ind - 1, ms[0])
    mx = (mean_coord_l.x + mean_coord_r.x ) / 2
    my = (mean_coord_l.y + mean_coord_r.y ) / 2

    index = 0
    for m in ms
        coord = indexToCood index, m

        unless coord.cr == coord.rr
            m.setInitRotation 180
        # m.setOrigin(coord.x, 0, coord.y)
        m.setOrigin(coord.x - mx, 0, coord.y - my)

        index++

updateGrid = (ms, delta) ->
    meterial = Session.get 'meterial'
    meterial.wireframe = Session.get 'wireframe'

    angle += delta * 2

    for m in ms
        ang_deg = (Math.sin(angle + 0.1*m.ori.z) + 1) * 15
        m.transform (ang_deg)

        amplitude = Session.get 'amplitude'
        wavelength = Session.get 'wavelength'
        wavespeed = Session.get 'wavespeed'
        isReal = Session.get 'real'

        feature = (x, y) ->
            z = feature_wave(x, y, wave_delta*wavespeed, amplitude, wavelength)
            z += feature_gaussian(x, y, wave_delta*2, 0, 0, 60, 60, amplitude * 5)
            return z

        x = m.ori.x
        y = m.ori.z

        vert = feature x, y

        dx = feature(x+1, y) - feature(x-1, y)
        dy = feature(x, y+1) - feature(x, y-1)
        dz = vert - m.ori.y

        deg_x = Math.atan(dx / 2)
        deg_y = Math.atan(dy / 2)

        range = (v, l, h) ->
            return Math.max(l, Math.min(v, h))

        motor_speed = dz / delta
        if isReal
            if motor_speed > 0 then motor_speed = range(motor_speed, 6.25, 10) else motor_speed = range(motor_speed, -10, -6.25)
            if Math.abs(delta * motor_speed) > Math.abs(dz)
                motor_speed = 0

            deg_x = range deg_x, (-Math.PI / 6), (Math.PI / 6)
            deg_y = range deg_x, (-Math.PI / 6), (Math.PI / 6)


        m.setRotationH (Math.atan deg_x)
        m.setRotationV (Math.atan deg_y)

        m.setOrigin x, m.ori.y + motor_speed * delta, y

        m.update()


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

    nWidth = Math.round Router.current().params._width if Router.current().params._width
    nHight = Math.round Router.current().params._height if Router.current().params._height
    if Router.current().params._width
        Session.set 'amplitude', 4
        Session.set 'wavelength', 11
        Session.set 'wavespeed', 2

    init = ->
        container = document.getElementById 'container'
        width = container.clientWidth
        height = container.clientHeight

        # // scene

        scene = new THREE.Scene
        camera = new THREE.PerspectiveCamera 60, width / height, 1, 2000
        camera.position.z = camz
        camera.position.y = camy
        camera.position.x = camx
        camera.lookAt(new THREE.Vector3( 0, 0, 0))

        controls = new THREE.FirstPersonControls camera
        controls.movementSpeed = 50
        controls.lookSpeed = 0.1
        controls.lookAt(new THREE.Vector3( 0, 0, 0))

        ambient = new THREE.AmbientLight 0x050505
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

        # moving_plane = new THREE.PlaneGeometry( 200, 200, n_plane_edge - 1, n_plane_edge - 1)
        # moving_plane.applyMatrix( new THREE.Matrix4().makeRotationX( - Math.PI / 2) )

        # material = new THREE.MeshPhongMaterial( { color: 0xe0dfdb, specular: 0xe0dfdb, metal: true, wireframe: true } )

        # mesh = new THREE.Mesh( moving_plane, material )
        # scene.add mesh

        models = generateModels (nWidth*nHight), edgeWidth
        addModelScene models, scene
        setGrid(models, nWidth)

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
        camera.updateProjectionMatrix()

        renderer.setSize width, height

        controls.handleResize()

    animate = ->

        requestAnimationFrame animate
        render()

    render = ->
        delta = clock.getDelta()

        # Get Global Data
        amplitude = Session.get 'amplitude'
        wavelength = Session.get 'wavelength'

        wave_delta += delta * 5

        # for i in [0..moving_plane.vertices.length-1]
        #     x = moving_plane.vertices[i].x
        #     y = moving_plane.vertices[i].z
        #     moving_plane.vertices[i].y = feature_wave(x,y,wave_delta, amplitude, wavelength)
        #     moving_plane.vertices[i].y += feature_gaussian(x,y,wave_delta, 0, 0, 15, 15, amplitude * 5)

        # moving_plane.verticesNeedUpdate = true
        # moving_plane.normalsNeedUpdate = true

        # moving_plane.computeFaceNormals()
        # moving_plane.computeVertexNormals()

        updateGrid models, delta

        controls.update delta
        renderer.render scene, camera

    init()
    animate()


Template.main.onRendered ->
    webGLStart() 
