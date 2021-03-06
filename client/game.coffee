class @Game
  @stage = 0
  constructor: ->
    @stage = new Stage

    @stage.setupListeners()
    
    @stage.addPlanet 720, 395, "#666", 200, 150
    @stage.addPlanet 800, 120, "#666", 20, 60
    @stage.addPlanet 660, 680, "#666", 20, 60

    @stage.addPlayer 200, 200, '#2178DB'
    @stage.addPlayer 1200, 500, '#E0351B'

    setInterval =>
      @stage.physics.step()
      @stage.render()
    , 42

class Player
  constructor: (@color, @x = 700, @y = 300, @target = 0, @health = 5) ->
    @target = new Vector(0, 80)
    @particle = new Particle 1, false
    @particle.moveTo new Vector(@x, @y)
    @particle.setRadius 20

class Planet
  constructor: (@color, @x = 700, @y = 300, @mass, @radius, physics, collide) ->
    @particle = new Particle mass, false
    @particle.moveTo new Vector(@x, @y)
    @particle.setRadius radius
    @particle.behaviours.push collide
    collide.pool.push @particle
    physics.particles.push @particle

class Bullet
  constructor: (x, y, mass = 3, @radius = 40, @color = "#ffffff", fixed = false) ->
    @particle = new Particle mass, fixed
    @particle.moveTo new Vector(x, y)
    @particle.setRadius radius

class Stage
  width = 1440
  height = 790
  
  constructor: (@game) ->
    @physics = new Physics
    @physics.integrator = new ImprovedEuler
    @physics.viscosity = 0.0001
    @bounds = new EdgeBounce new Vector(0, 0), new Vector(width, height)
    @collide = new Collision yes, (p, o) =>
      @hitPlayer p.id
      @removeBullet o.id
    @attraction = new ConstantForce new Vector 0, 0
    @ctx = document.getElementById("canvas").getContext('2d')
    @bullets = []
    @players = []
    @planets = []

  hitPlayer: (id) ->
    for p, i in @players
      if p.particle.id is id
        p.health--
        break

  removeBullet: (id) ->
    # Find and remove graphics
    for e, i in @bullets
      if e.particle.id is id
        @bullets.splice i, 1
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

  fireBullet: (player) ->
    target = player.target
    console.log player.particle
    offset = target.clone().norm().scale 27

    @addBullet(player.x+offset.x, player.y+offset.y, 1, 5, "#fff")
    particle = @physics.particles[@physics.particles.length-1]
    particle.acc.add(target.clone().scale(120))
    # Push all planet positions as attractions
    for planet in @planets
      particle.behaviours.push new Attraction(planet.particle.pos, 2000, planet.mass)

  addPlanet: (x, y, color, mass, radius) ->
    planet = new Planet color, x, y, mass, radius, @physics, @collide
    @planets.push planet

  addPlayer: (x, y, color, mass, radius, fixed) ->
    player = new Player color, x, y
    player.particle.behaviours.push @attraction, @collide
    @collide.pool.push player.particle
    @physics.particles.push player.particle
    @players.push player

  addBullet: (x, y, mass, radius, color) ->
    e = new Bullet(x, y, mass, radius, color)
    e.particle.behaviours.push @attraction, @collide
    @collide.pool.push e.particle
    @physics.particles.push e.particle
    @bullets.push e

  render: ->
    @ctx.clearRect 0, 0, width, height
    @drawPlayers()
    @drawBullets()
    @drawPlanets()

  drawPlanets: ->
    for p in @planets
      @ctx.beginPath()
      @ctx.arc(p.particle.pos.x, p.particle.pos.y, p.radius+5, 0, 2 * Math.PI, false)
      @ctx.fillStyle = p.color
      @ctx.fill()

  drawBullets: ->
    # Draw bullets
    @ctx.beginPath()
    for e in @bullets
      #@ctx.drawImage e.image, e.particle.pos.x - e.radius, e.particle.pos.y - e.radius, e.radius*2, e.radius*2
      @ctx.beginPath()
      @ctx.arc(e.particle.pos.x, e.particle.pos.y, e.radius, 0, 2 * Math.PI, false)
      @ctx.fillStyle = e.color
      @ctx.fill()

  drawPlayers: ->
    for p in @players
      @drawRings p
      @drawTarget p.x, p.y, p.target
      @drawPlayer p

  drawRings: (player) ->
    for i in [player.health-1..0] by -1
      @ctx.beginPath()
      @ctx.arc(player.x, player.y, 23+(i*3), 0, 2 * Math.PI, false)
      @ctx.fillStyle = "#222"
      @ctx.fill()

      @ctx.beginPath()
      @ctx.arc(player.x, player.y, 22+(i*3), 0, 2 * Math.PI, false)
      @ctx.fillStyle = "#111"
      @ctx.fill()
    
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

    @ctx.lineWidth = 22
    @ctx.strokeStyle = "#111"
    @ctx.lineCap = "round"
    @ctx.beginPath()
    @ctx.moveTo(x, y)
    @ctx.lineTo(x+vector.x/2, y+vector.y/2)
    @ctx.stroke()

    @ctx.lineWidth = 19
    @ctx.strokeStyle = "#222"
    @ctx.lineCap = "round"
    @ctx.beginPath()
    @ctx.moveTo(x, y)
    @ctx.lineTo(x+vector.x/2, y+vector.y/2)
    @ctx.stroke()

    @ctx.lineWidth = 0.1
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
        @fireBullet @players[0]
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