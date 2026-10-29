import bpy, math, os
from mathutils import Vector

root = r'C:\Users\Bruno\Documents\ChatGPT\Weapon Evolution\assets\horror_menu'
os.makedirs(root, exist_ok=True)
old = bpy.context.window.scene
source = bpy.data.objects['Rodeur Rig']
scene = bpy.data.scenes.new('Horror menu study')
bpy.context.window.scene = scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x, scene.render.resolution_y, scene.render.resolution_percentage = 1200, 700, 100
scene.world = bpy.data.worlds.new('Horror menu night')
scene.world.color = (.025,.03,.04)
rig = source.copy()
rig.data = source.data.copy()
scene.collection.objects.link(rig)
rig.location = (-1,0,0)
for child in source.children:
    obj = child.copy()
    scene.collection.objects.link(obj)
    obj.parent = rig
    for mod in obj.modifiers:
        if mod.type == 'ARMATURE':
            mod.object = rig
rig.animation_data.action = bpy.data.actions.get('Rodeur Idle')

def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color,1)
    mat.use_nodes = True
    mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (*color,1)
    return mat

street = material('Wet asphalt', (.045,.055,.06))
concrete = material('Concrete', (.09,.10,.105))
window = material('Dark windows', (.016,.022,.026))
def box(name, center, size, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    obj.data.materials.append(mat)
    return obj
box('Road', (0,0,-.18), (28,48,.35), street)
box('Left building', (-9,0,5), (5,30,10), concrete)
box('Right building', (9,0,6), (5,30,12), concrete)
box('Back wall', (0,17,4), (18,2,8), concrete)
for x in (-6.45,6.45):
    for y in (-8,-3,2,7,12):
        for z in (3,6,9):
            box('Window', (x,y,z), (.08,1.5,1.8), window)
bpy.ops.object.camera_add(location=(3,-14,4.3))
cam = bpy.context.object
cam.name = 'Menu camera'
cam.rotation_euler = (Vector((-1,1,1.6))-cam.location).to_track_quat('-Z','Y').to_euler()
cam.data.lens = 45
scene.camera = cam
for name, location, color, power, target in [
    ('Moon', (1,-7,9), (.56,.70,1.0), 1600, (-1,0,1.5)),
    ('Distant warning', (-7,8,4), (1.0,.23,.10), 900, (0,1,1.4)),
]:
    bpy.ops.object.light_add(type='AREA', location=location)
    light = bpy.context.object
    light.name = name
    light.data.energy = power
    light.data.color = color
    light.data.shape = 'DISK'
    light.data.size = 5
    light.rotation_euler = (Vector(target)-light.location).to_track_quat('-Z','Y').to_euler()
scene.frame_set(10)
assert scene.camera and len(rig.pose.bones)>0
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = os.path.join(root, 'HorrorMenuStudy.png')
bpy.ops.render.render(write_still=True)
path = os.path.join(root, 'HorrorMenuStudy.blend')
bpy.ops.wm.save_as_mainfile(filepath=path, copy=True)
bpy.context.window.scene = old
result = {'file':path,'image':scene.render.filepath,'rig_bones':len(rig.pose.bones)}
