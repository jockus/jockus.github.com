require("three.min.js

num_meshes = 20
meshes = []


init()
animate()

init ->

    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
    camera.position.z = 1000

    scene = new THREE.Scene()

    geometry = new THREE.CubeGeometry( 200, 200, 200 )
    material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: false } )

    for i in [0, 20]
        mesh = new THREE.Mesh( geometry, material )
        mesh.position.x = ( i - num_meshes / 2.0 ) * 100
        scene.add( mesh )
        meshes[i] = mesh          

    mesh = new THREE.Mesh( geometry, material )
    scene.add( mesh )

    renderer = new THREE.CanvasRenderer()
    renderer.setSize( window.innerWidth, window.innerHeight )

    document.body.appendChild( renderer.domElement )



animate ->

    requestAnimationFrame( animate )

   for i in [0, 20]
        mesh = meshes[i]
        mesh.rotation.x += 0.01
        mesh.rotation.y += 0.02


    
    renderer.render( scene, camera )
