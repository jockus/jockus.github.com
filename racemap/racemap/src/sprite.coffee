class Sprite
    constructor: (@go, filename, @numFrames, startFrame, endFrame, @absWidth, @absHeight) ->
        spriteMap = THREE.ImageUtils.loadTexture( filename, null, @onLoad )
        @spriteMat = new THREE.SpriteMaterial( { map: spriteMap, color: 0xffffff, useScreenCoordinates: false, scaleByViewport: true, depthTest: false , opacity: 0.75, transparent: true} )
        @sprite = new THREE.Sprite( @spriteMat );

        #@spriteMat.uvScale.set(1 / @numFrames, 1)
        #@spriteTween = new TWEEN.Tween( { frame: startFrame, numFrames: @numFrames, spriteMat: @spriteMat} ).to( { frame: endFrame }, 1000 ).repeat(Infinity).onUpdate( ->
        #    frameX = ( 1 / @numFrames ) * Math.floor( @frame )
        #    @spriteMat.uvOffset.set( frameX, 0 ) )

        #@spriteTween.start()

        resources.scene.add( @sprite )

    update: () ->
        @sprite.updateMatrix()

    onLoad: (texture) =>
        if @absWidth? and @absHeight?
            @sprite.scale.set( @absWidth * physicsScale, @absHeight * physicsScale, 1 )
        else
            @sprite.scale.set( Math.floor( texture.image.width / @numFrames ), texture.image.height, 1 )

    parse: ( data ) ->
        @spriteMat.uvOffset.set( data.uvOffset.x, data.uvOffset.y )

    toJSON: () ->
        { uvOffset: @spriteMat.uvOffset }
