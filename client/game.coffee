class @Game
  @stage = 0
  constructor: ->
    @stage = new Stage @
    # Add players
    @players = []
    @players.push new Player '#2178DB', 100, 100
    @players.push new Player '#D1460F'

    @setupListeners()
    
    for i in [1..1]
      @stage.addElement(400, 200, 20, 200)

    setInterval =>
      @stage.physics.step()
      @stage.renderElements()
    , 42
    
  setupListeners: ->

    $(document).keydown (event) =>

      console.log @players
      target = @players[1].target
      if event.keyCode is 32
        @stage.addElement(700, 300, 1, 10)
        particle = @stage.physics.particles[@stage.physics.particles.length-1]
        particle.acc.add(target.clone().scale(100))
        particle.behaviours.push new Attraction(@stage.physics.particles[0].pos)
      if event.keyCode is 37
        console.log "Rotating left"
        target.rotate -Math.PI/50
      else if event.keyCode is 39
        console.log "Rotating right"
        target.rotate Math.PI/50
      else if event.keyCode is 38
        console.log "Increasing power"
        if target.mag() <= 200
          target.increment 10
      else if event.keyCode is 40
        console.log "Decreasing power"
        if target.mag() > 30
          target.increment -10

class Player
  constructor: (@color, @x = 700, @y = 300, @target = 0) ->
    @target = new Vector(0, 100)

class Stage
  width = 1440
  height = 600
  
  constructor: (@game) ->
    @physics = new Physics
    @physics.integrator = new ImprovedEuler
    @physics.viscosity = 0.001
    @bounds = new EdgeBounce new Vector(0, 0), new Vector(width, height)
    @collide = new Collision()
    @attraction = new ConstantForce new Vector 0, 0
    @ctx = document.getElementById("canvas").getContext('2d')
    @elements = []

  addElement: (x, y, mass, radius) ->
    e = new Element(x, y, mass, radius)
    e.particle.behaviours.push @attraction, @collide
    @collide.pool.push e.particle
    @physics.particles.push e.particle
    @elements.push e

  renderElements: ->
    @ctx.clearRect 0, 0, width, height
    @drawTargets()
    # Draw bullets
    @ctx.beginPath()
    for e in @elements
      #@ctx.drawImage e.image, e.particle.pos.x - e.radius, e.particle.pos.y - e.radius, e.radius*2, e.radius*2
      @ctx.beginPath()
      @ctx.arc(e.particle.pos.x, e.particle.pos.y, e.radius, 0, 2 * Math.PI, false)
      @ctx.fillStyle = '#999'
      @ctx.fill()
    @drawPlayers()

  drawPlayers: ->
    for p in @game.players
      @drawPlayer p

  drawTargets: ->
    for p in @game.players
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
    @ctx.lineTo(x+vector.x, y+vector.y)
    @ctx.stroke()

    @ctx.lineWidth = 2
    @ctx.strokeStyle = "#111"
    @ctx.lineCap = "round"
    @ctx.beginPath()
    @ctx.moveTo(x, y)
    @ctx.lineTo(x+vector.x, y+vector.y)
    @ctx.stroke()

class Element
  constructor: (x, y, mass = 3, @radius = 40) ->
    @particle = new Particle mass
    @particle.moveTo new Vector(x, y)
    @particle.setRadius radius