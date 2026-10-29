import bpy, math
from mathutils import Vector

# A separate scene keeps the user's current Blender scene intact.
scene = bpy.data.scenes.new('City Zombie Concepts')
collection = scene.collection
def material(name, color, metallic=0):
    m = bpy.data.materials.new(name); m.diffuse_color = (*color, 1); m.metallic = metallic; m.roughness = .8
    m.use_nodes = True; shader = m.node_tree.nodes.get('Principled BSDF'); shader.inputs['Base Color'].default_value = (*color, 1); shader.inputs['Metallic'].default_value = metallic; shader.inputs['Roughness'].default_value = .8
    return m
skin = material('Infected skin', (.29, .36, .22))
coat = material('Rags', (.18, .21, .22))
leather = material('Worn leather', (.30, .23, .18))
bone = material('Bone and wraps', (.7, .68, .54))
rust = material('Rust', (.42, .25, .17), .5)
eye = material('Infected eyes', (.9, .22, .06))
def cube(name, center, size, mat, tilt=0):
    mesh = bpy.data.meshes.new(name); mesh.from_pydata([(-.5,-.5,-.5),(.5,-.5,-.5),(.5,.5,-.5),(-.5,.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(.5,.5,.5),(-.5,.5,.5)], [], [(0,1,2,3),(4,7,6,5),(0,4,5,1),(1,5,6,2),(2,6,7,3),(4,0,3,7)])
    ob = bpy.data.objects.new(name, mesh); collection.objects.link(ob); ob.location = center; ob.scale = size; ob.rotation_euler[1] = tilt; ob.data.materials.append(mat); return ob
def body(label, x, width, height):
    cube(label+' torso', (x,0,3.3*height),(1.8*width,.85,2.3*height),coat)
    cube(label+' head', (x,0,5.05*height),(.95,.82,1.05),skin)
    for s in (-1,1):
        cube(label+' arm', (x+s*1.15*width,0,3.15*height),(.62*width,.65,2.3*height),skin)
        cube(label+' leg', (x+s*.48*width,0,1.15*height),(.76*width,.72,2.3*height),coat)
        cube(label+' eye', (x+s*.22,-.43,5.12*height),(.13,.08,.09),eye)
body('Rodeur',-4,1,1)
for s in (-1,1): cube('Rodeur strap',(-4+s*.45,-.48,3.4),(.12,.09,1.7),leather,s*.1)
cube('Rodeur torn cloth',(-4.4,-.47,2.5),(.7,.1,.5),coat,-.1)
for i in range(3): cube('Rodeur stitch',(-3.75,-.52,3.05+i*.12),(.32,.06,.035),bone,.2)
body('Affame',0,.8,.94)
cube('Affame hood',(0,.28,4.95),(.98,.28,.65),coat)
for s in (-1,1):
    cube('Affame hood edge',(s*.44,-.33,4.92),(.18,.25,.68),coat,s*.12)
    cube('Affame wrist',(s*.92,0,2.2),(.7,.7,.22),leather)
    for i in (-1,0,1): cube('Affame claw',(s*.92+i*.16,-.12,1.7),(.09,.12,.48),bone)
for i in range(3): cube('Affame ribs',(0,-.46,3.5-i*.2),(.7-i*.12,.1,.07),bone)
body('Colosse',4,1.35,1.2)
for s in (-1,1):
    cube('Colosse shoulder',(4+s*1.55,0,4.7),(1.2,1.05,.26),rust,s*.12)
    cube('Colosse wrist',(4+s*1.55,0,3.0),(1,.9,.3),leather)
cube('Colosse armor',(4.2,-.5,4.05),(1.05,.13,.72),rust,-.14)
cube('Colosse belt',(4,0,2.85),(2.4,1,.22),leather)
cube('Colosse buckle',(4,-.55,2.85),(.4,.12,.3),rust)
camera_data=bpy.data.cameras.new('Concept camera'); camera=bpy.data.objects.new('Concept camera',camera_data); collection.objects.link(camera)
camera.location=(9,-19,11); camera.rotation_euler=(Vector((0,0,3))-camera.location).to_track_quat('-Z','Y').to_euler(); camera_data.type='ORTHO'; camera_data.ortho_scale=15; scene.camera=camera
light_data=bpy.data.lights.new('Softbox','AREA'); light_data.energy=1700; light_data.shape='DISK'; light_data.size=10
light=bpy.data.objects.new('Softbox',light_data); collection.objects.link(light); light.location=(0,-7,12); light.rotation_euler=(Vector((0,0,3))-light.location).to_track_quat('-Z','Y').to_euler()
scene.render.engine='BLENDER_EEVEE'; scene.render.resolution_x=1200; scene.render.resolution_y=700; scene.render.resolution_percentage=100
scene.world=bpy.data.worlds.new('Concept world'); scene.world.color=(.08,.08,.08)
path=r'C:\Users\Bruno\Documents\ChatGPT\Weapon Evolution\assets\city_zombie_concepts.blend'
bpy.ops.wm.save_as_mainfile(filepath=path, copy=True)
print('Created concept scene:', path)
