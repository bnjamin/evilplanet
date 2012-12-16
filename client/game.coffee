class Game
  constructor: ->
    stage = new Stage
    
    for i in [1..50]
      stage.addElement(Random(500), Random(500))

    setInterval ->
      stage.physics.step()
      stage.renderElements()
    , 42
    
class Stage
  width = 800
  height = 600
  
  constructor: ->
    @physics = new Physics
    @physics.integrator = new Verlet
    @bounds = new EdgeBounce new Vector(0, 0), new Vector(width, height)
    @collide = new Collision()
    @attraction = new ConstantForce new Vector 0, 30
    @ctx = document.getElementById("canvas").getContext('2d')
    @elements = []

  addElement: (x, y) ->
    e = new Element(x, y)
    e.particle.setRadius 20
    e.particle.behaviours.push @attraction, @bounds, @collide
    @collide.pool.push e.particle
    @physics.particles.push e.particle
    @elements.push e

  renderElements: ->
    @ctx.beginPath()
    @ctx.clearRect 0, 0, width, height
    for e in @elements
      @ctx.drawImage e.image(), e.particle.pos.x - 20, e.particle.pos.y - 20

class Element
  constructor: (x, y) ->
    @particle = new Particle
    @particle.moveTo new Vector(x), new Vector(y)

  image: -> 
    (new Earth).image

class Earth
  constructor: ->
    @image = new Image()
    @image.src = '/img/earth.png'