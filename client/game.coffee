class @Game
  @stage = 0
  constructor: ->
    @stage = new Stage @
    # Add players
    # @players = []
    # @players.push 
    # player1 = new Player '#2178DB', 200, 200
    # player1.particle 
    # @players.push new Player '#D1460F', 1240, 590

    @stage.setupListeners()
    
    for i in [1..1]
      @stage.addElement(720, 395, 20, 200, "#666", false)

    @stage.addPlayer()

    setInterval =>
      @stage.physics.step()
      @stage.renderElements()
    , 42

class Player
  constructor: (@color, @x = 700, @y = 300, @target = 0) ->
    @target = new Vector(0, 100)
    @particle = new Particle 1, false
    @particle.moveTo new Vector(200, 200)
    @particle.setRadius 20

class Stage
  width = 1440
  height = 790
  
  constructor: (@game) ->
    @physics = new Physics
    @physics.integrator = new ImprovedEuler
    @physics.viscosity = 0.001
    @bounds = new EdgeBounce new Vector(0, 0), new Vector(width, height)
    @collide = new Collision yes, (p, o) =>
      @removeElement o.id
    @attraction = new ConstantForce new Vector 0, 0
    @ctx = document.getElementById("canvas").getContext('2d')
    @elements = []
    @players = []

  removeElement: (id) ->
    # Find and remove graphics
    for e, i in @elements
      if e.particle.id is id
        @elements.splice i, 1
        break
    # Find and remove particle
    for p, i in @physics.particles
      if p.id is id
        @physics.particles.splice i, 1
        break
    # Find and remove from collision pool
    for p, i in @collide.pool
      if p.id is id
        @collide.pool.splice i, 1
        break

  addBullet: (player) ->
    target = player.target
    console.log player.particle
    offset = target.clone().norm().scale 27

    @addElement(player.x+offset.x, player.y+offset.y, 1, 5, "#fff")
    particle = @physics.particles[@physics.particles.length-1]
    particle.acc.add(target.clone().scale(100))
    particle.behaviours.push new Attraction(@physics.particles[0].pos)

  addPlayer: (x, y, mass, radius, color, fixed) ->
    player = new Player '#2178DB', 200, 200
    player.particle.behaviours.push @attraction, @collide
    @collide.pool.push player.particle
    @physics.particles.push player.particle
    @elements.push player
    @players.push player

  addElement: (x, y, mass, radius, color, fixed) ->
    e = new Element(x, y, mass, radius, color, fixed)
    e.particle.behaviours.push @attraction, @collide
    @collide.pool.push e.particle
    @physics.particles.push e.particle
    @elements.push e

  renderElements: ->
    @ctx.clearRect 0, 0, width, height
    @drawTargets()
    @drawBullets()
    @drawPlayers()

  drawBullets: ->
    # Draw bullets
    @ctx.beginPath()
    for e in @elements
      #@ctx.drawImage e.image, e.particle.pos.x - e.radius, e.particle.pos.y - e.radius, e.radius*2, e.radius*2
      @ctx.beginPath()
      @ctx.arc(e.particle.pos.x, e.particle.pos.y, e.radius+5, 0, 2 * Math.PI, false)
      @ctx.fillStyle = e.color
      @ctx.fill()

  drawPlayers: ->
    for p in @players
      @drawPlayer p

  drawTargets: ->
    for p in @players
      @drawTarget p.x, p.y, p.target
    
  drawPlayer: (player) ->
    # Render player
    @ctx.beginPath()
    @ctx.arc(player.x, player.y, 20, 0, 2 * Math.PI, false)
    @ctx.fillStyle = player.color
    @ctx.fill()

  drawVector: (vector) ->
    @ctx.beginPath()
    @ctx.moveTo(700, 300)
    @ctx.lineTo(700+vector.x, 300+vector.y)
    @ctx.stroke()

  drawTarget: (x, y, vector) ->

    @ctx.lineWidth = 20
    @ctx.strokeStyle = "#222"
    @ctx.lineCap = "round"
    @ctx.beginPath()
    @ctx.moveTo(x, y)
    @ctx.lineTo(x+vector.x/2, y+vector.y/2)
    @ctx.stroke()

    @ctx.lineWidth = 2
    @ctx.strokeStyle = "#111"
    @ctx.lineCap = "round"
    @ctx.beginPath()
    @ctx.moveTo(x, y)
    @ctx.lineTo(x+vector.x/2, y+vector.y/2)
    @ctx.stroke()

  setupListeners: ->
    $(document).keydown (event) =>
      # Player 1 controls
      target = @players[0].target
      if event.keyCode is 32 # space
        @addBullet @players[0]
      if event.keyCode is 37 # left
        console.log "Rotating left"
        target.rotate -Math.PI/50
      if event.keyCode is 39 # right
        console.log "Rotating right"
        target.rotate Math.PI/50
      if event.keyCode is 38 # up
        console.log "Increasing power"
        if target.mag() < 200
          target.increment 10
      if event.keyCode is 40 # down
        console.log "Decreasing power"
        if target.mag() > 10
          target.increment -10

class Element
  constructor: (x, y, mass = 3, @radius = 40, @color = "#ffffff", fixed = false) ->
    @particle = new Particle mass, fixed
    @particle.moveTo new Vector(x, y)
    @particle.setRadius radius