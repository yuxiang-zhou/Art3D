class TriDM

  # private vatriables
  cos30 = Math.sqrt(3) / 2
  sin30 = 0.5
  cylinder_height = 20

  # private functions
  getPhi = (ang) ->
    return 0

  # public members
  ori: new THREE.Vector3(0, 0, 0)
  rot: 0
  roth: 0
  rotv: 0

  phi: 0
  theta: 0
  thetaDeg: 0

  c: 0
  a: 0
  b: 0

  constructor: (edgeSize, material) ->

    @meshs = new THREE.Object3D()

    @c = edgeSize / 2
    @a = @c / Math.sqrt(3)
    @b = 2 * @a

    @geometry = new THREE.Geometry()

    @geometry.vertices.push(
      new THREE.Vector3( -@b*cos30, 0, -@b*sin30 ),
      new THREE.Vector3( @b*cos30, 0, -@b*sin30 ),
      new THREE.Vector3( 0, 0, @b),
      new THREE.Vector3( @a*cos30, 0, @a*sin30 ),
      new THREE.Vector3( -@a*cos30, 0, @a*sin30 ),
      new THREE.Vector3( 0, 0, -@a),
      new THREE.Vector3( 0, 0, 0 )
    )

    @geometry.faces.push(
      new THREE.Face3( 0, 6, 5 ),
      new THREE.Face3( 5, 6, 1 ),
      new THREE.Face3( 1, 6, 3 ),
      new THREE.Face3( 3, 6, 2 ),
      new THREE.Face3( 2, 6, 4 ),
      new THREE.Face3( 4, 6, 0 )
    )

    @geometry.computeBoundingSphere()
    @geometry.computeFaceNormals()
    @geometry.computeVertexNormals()

    @cylinder = new THREE.CylinderGeometry( 1, 1, cylinder_height, 8 )

    @material = material

    mesh = new THREE.Mesh( @geometry, @material )
    mesh.material.side = THREE.DoubleSide
    @meshs.add mesh

    mesh = new THREE.Mesh( @cylinder, @material )
    @meshs.add mesh

  transform: (ang) ->
    ang %= 90
    @theta = ang * Math.PI / 180
    @thetaDeg = ang
    @phi = getPhi @theta

  setOrigin: (x, y, z) ->
    hight_limit = cylinder_height
    if y < hight_limit
      @ori = new THREE.Vector3(x, y, z)
    else
      @ori = new THREE.Vector3(x, hight_limit, z)

  setInitRotation: (deg) ->
    @rot = deg * Math.PI / 180

  setRotationH: (rad) ->
    @roth = rad

  setRotationV: (rad) ->
    @rotv = rad

  update: ->

    # Triangle Animation
    @geometry.vertices[0].x = -@b*Math.cos(@phi)*cos30
    @geometry.vertices[0].y = -@b*Math.sin(@phi)
    @geometry.vertices[0].z = -@b*Math.cos(@phi)*sin30

    @geometry.vertices[1].x = @b*Math.cos(@phi)*cos30
    @geometry.vertices[1].y = -@b*Math.sin(@phi)
    @geometry.vertices[1].z = -@b*Math.cos(@phi)*sin30

    @geometry.vertices[2].x = 0
    @geometry.vertices[2].y = -@b*Math.sin(@phi)
    @geometry.vertices[2].z = @b*Math.cos(@phi)

    @geometry.vertices[3].x = @a*Math.cos(@theta)*cos30
    @geometry.vertices[3].y = -@a*Math.sin(@theta)
    @geometry.vertices[3].z = @a*Math.cos(@theta)*sin30

    @geometry.vertices[4].x = -@a*Math.cos(@theta)*cos30
    @geometry.vertices[4].y = -@a*Math.sin(@theta)
    @geometry.vertices[4].z = @a*Math.cos(@theta)*sin30

    @geometry.vertices[5].x = 0
    @geometry.vertices[5].y = -@a*Math.sin(@theta)
    @geometry.vertices[5].z = -@a*Math.cos(@theta)

    @geometry.vertices[6].x = 0
    @geometry.vertices[6].y = 0
    @geometry.vertices[6].z = 0

    @geometry.applyMatrix (
      new THREE.Matrix4().makeRotationY(@rot)
    )

    @geometry.applyMatrix (
      new THREE.Matrix4().makeRotationZ(@roth)
    )

    @geometry.applyMatrix (
      new THREE.Matrix4().makeRotationX(-@rotv)
    )

    @geometry.applyMatrix (
      new THREE.Matrix4().makeTranslation(@ori.x, @ori.y, @ori.z)
    )

    @geometry.verticesNeedUpdate = true
    @geometry.normalsNeedUpdate = true

    @geometry.computeBoundingSphere()
    @geometry.computeFaceNormals()
    @geometry.computeVertexNormals()

    # cylinder animation

    @cylinder.computeBoundingBox()
    @cylinder.computeBoundingSphere()

    coord_cylinder = @cylinder.boundingSphere.center

    @cylinder.applyMatrix (
      new THREE.Matrix4().makeTranslation(
        @ori.x - coord_cylinder.x,
        0,
        @ori.z - coord_cylinder.z
      )
    )

    base = cylinder_height / 2
    h = @cylinder.boundingBox.max.y - @cylinder.boundingBox.min.y

    for v in @cylinder.vertices
      v.y = (v.y + base) * (@ori.y + base) / h - base

    @cylinder.verticesNeedUpdate = true
    @cylinder.normalsNeedUpdate = true


    @cylinder.computeFaceNormals()
    @cylinder.computeVertexNormals()

@TriDM = TriDM
