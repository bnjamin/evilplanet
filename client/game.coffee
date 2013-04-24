class @Game
  @stage = 0
  constructor: ->
    @stage = new Stage

    @setupListeners()
    
    for i in [1..1]
      @stage.addElement(400, 200, 40, 40)

    setInterval =>
      @stage.physics.step()
      @stage.renderElements()
    , 42
    
  setupListeners: ->

    $(document).keydown (event) =>
      if event.keyCode is 32
        @stage.addElement(400, 400, 1, 20)
        particle = @stage.physics.particles[@stage.physics.particles.length-1]
        particle.acc.add(new Vector(5000, -5000))
        particle.behaviours.push new Attraction(@stage.physics.particles[0].pos)

class Stage
  width = 800
  height = 600
  
  constructor: ->
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
    @ctx.beginPath()
    @ctx.clearRect 0, 0, width, height
    for e in @elements
      @ctx.drawImage e.image, e.particle.pos.x - e.radius, e.particle.pos.y - e.radius, e.radius*2, e.radius*2

class Element
  constructor: (x, y, mass = 3, @radius = 40) ->
    @particle = new Particle mass
    @particle.moveTo new Vector(x, y)
    @particle.setRadius radius
    @image = new Image()
    @image.src = '/img/earth.png'

class Earth
  constructor: ->
    @image = new Image()
    @image.src = '/img/earth.png'