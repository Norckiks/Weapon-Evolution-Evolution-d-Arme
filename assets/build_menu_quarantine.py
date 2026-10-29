"""Standalone Blender scene; export a primitive bridge and a bevelled FBX master."""
import bpy, json, math, random
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path(r'C:\Users\Bruno\Documents\ChatGPT\Weapon Evolution\assets\horror_menu\quarantine')
ROOT.mkdir(parents=True, exist_ok=True)
old_scene = bpy.context.window.scene
scene = bpy.data.scenes.new('Menu_Quarantine_20261029')
bpy.context.window.scene = scene
random.seed(29)
records = []
palette = {'concrete':(.25,.28,.29), 'steel':(.13,.18,.19), 'rust':(.37,.18,.10), 'yellow':(.71,.51,.20), 'dark':(.035,.055,.065), 'red':(.62,.10,.055), 'light':(.83,.76,.52), 'wood':(.30,.24,.16)}
mats = {}
for name, color in palette.items():
    m = bpy.data.materials.new('Quarantine_'+name)
    m.diffuse_color = (*color,1)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color,1)
    bsdf.inputs['Roughness'].default_value = .78
    if name == 'light':
        bsdf.inputs['Emission Color'].default_value = (*color,1)
        bsdf.inputs['Emission Strength'].default_value = 2
    mats[name] = m

R = Matrix(((1,0,0),(0,0,1),(0,-1,0)))
def part(name, pos, size, color='steel', rot=(0,0,0), shape='Block'):
    if shape == 'Cylinder':
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=.5, depth=1, location=pos)
    elif shape == 'Ball':
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=.5, location=pos)
    else:
        bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    ob=bpy.context.object
    ob.name=name
    ob.scale=size
    ob.rotation_euler=tuple(math.radians(v) for v in rot)
    ob.data.materials.append(mats[color])
    bpy.context.view_layer.update()
    q=ob.rotation_euler.to_matrix()
    if shape=='Cylinder':
        q=R @ q @ Matrix(((0,1,0),(0,0,1),(1,0,0)))
        dims=(size[2],size[0],size[1])
    else:
        q=R @ q @ R.transposed()
        dims=(size[0],size[2],size[1])
    p=R @ Vector(pos)
    records.append({'name':name,'shape':shape,'size':dims,'cf':list(p)+[q[i][j] for i in range(3) for j in range(3)],'color':[round(v*255) for v in palette[color]],'material':'Neon' if color=='light' else 'Concrete' if color=='concrete' else 'Wood' if color=='wood' else 'Metal'})
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if shape=='Block':
        bevel=ob.modifiers.new('Worn edges','BEVEL')
        bevel.width=min(.045,min(size)*.2)
        bevel.segments=2
        ob.modifiers.new('Corner normals','WEIGHTED_NORMAL')
    return ob

# Gate with fluted steel shutters, reinforcement, rivets and warning lamps.
for x in (-6,6):
    part('GatePier',(x,12,4),(.8,1.2,8),'concrete')
    part('PierCap',(x,12,8.1),(1.1,1.5,.24),'rust')
    part('BeaconBase',(x,12,8.4),(.45,.45,.3))
    part('WarningBeacon',(x,12,8.75),(.28,.28,.42),'red',shape='Cylinder')
part('GateHeader',(0,12,7.4),(11.6,1,.65))
for x in (-2.95,2.95):
    part('GatePanel',(x,12,3.6),(5.8,.22,6.7))
    for j in range(12):
        part('CorrugatedRib',(x-2.64+j*.48,11.82,3.6),(.075,.12,6.5),'rust' if j%5==0 else 'steel')
    for z in (.45,3.4,6.75):
        part('GateCrossbrace',(x,11.67,z),(5.7,.17,.16),'rust')
        for dx in (-2.5,2.5):
            part('Rivet',(x+dx,11.55,z),(.09,.09,.09),'yellow',shape='Ball')
part('GateSign',(0,11.35,7.6),(6.5,.15,.9),'yellow')
for x in (-2.8,2.8):
    part('SignBorder',(x,11.24,7.6),(.08,.05,.75),'dark')
for x in (-.45,.45):
    part('PullHandle',(x,11.48,3.4),(.08,.22,.7),'yellow')

# Side walls, broken boards and visible window frames.
for x in (-10,10):
    part('SideFacade',(x,8,5),(5,20,10),'concrete')
    for z in (3,6.5,9):
        for y in (0,4,8,12):
            inner=x+ (2.52 if x<0 else -2.52)
            part('WindowRecess',(inner,y,z),(.08,1.6,1.9),'dark')
            for dy in (-.86,.86): part('WindowJamb',(inner,y+dy,z),(.15,.12,2.15),'rust')
            part('WindowSill',(inner,y,z-1.05),(.4,2,.18))
            if y%8==0: part('BoardedWindow',(inner,y,z),(.19,2,.25),'wood',rot=(22,0,0))

# Jersey-style compound barricades with hazard strips and chipped feet.
for x,y in ((-4,4),(5,6)):
    part('BarrierFoot',(x,y,.25),(4.8,1.2,.5),'concrete')
    part('BarrierBody',(x,y,1),(4.4,.75,1.3),'concrete')
    part('BarrierCap',(x,y,1.8),(4.2,.5,.3),'yellow')
    for j in range(8):
        part('HazardStripe',(x-1.8+j*.5,y-.395,1.1),(.23,.025,.85),'dark',rot=(0,-24,0))
    for dx in (-1.9,1.9): part('BarrierBolt',(x+dx,y-.45,.65),(.12,.12,.12),'rust',shape='Ball')

# Floodlight mast, crossbar, housings and lenses.
part('MastFoot',(6.7,4,.18),(1.1,1.1,.35),'concrete')
part('Mast',(6.7,4,4.5),(.16,.16,8.6),shape='Cylinder')
part('LightArm',(6.1,4,8.6),(1.5,.2,.16))
for x in (5.6,6.5):
    part('FloodlightHousing',(x,3.8,8.5),(.7,.45,.5),rot=(15,0,0))
    part('FloodlightLens',(x,3.55,8.45),(.55,.04,.30),'light',rot=(15,0,0))

# Supply crates, fuel drums with separate hoops, scattered masonry.
for x,y,z in ((-6,7,.7),(-5.8,8.5,.7),(-6,7,2.1)):
    part('SupplyCrate',(x,y,z),(1.3,1.3,1.3),'wood')
    for dx in (-.5,.5): part('CrateBand',(x+dx,y-.67,z),(.1,.04,1.3))
for x,y in ((5,10),(6.2,10.2)):
    part('FuelDrum',(x,y,.9),(.9,.9,1.8),'rust',shape='Cylinder')
    for z in (.2,.9,1.6): part('DrumHoop',(x,y,z),(.96,.96,.1),shape='Cylinder')
for i in range(26):
    x=random.choice((-1,1))*random.uniform(4.5,7)
    y=random.uniform(-1,11)
    part('BrokenMasonry',(x,y,.12),(random.uniform(.15,.45),random.uniform(.2,.6),.2),'concrete',rot=(0,0,random.uniform(-80,80)))

# Export bridge: no HTTP or asset publication required. Bevels stay in the FBX master.
assert 100 < len(records) < 500
assert all(all(v>0 for v in r['size']) for r in records)
(ROOT/'MenuQuarantine.parts.json').write_text(json.dumps(records,separators=(',',':')),encoding='utf-8')
mesh_objects=[o for o in scene.objects if o.type=='MESH']
bpy.ops.object.select_all(action='DESELECT')
for o in mesh_objects: o.select_set(True)
bpy.context.view_layer.objects.active=mesh_objects[0]
bpy.ops.export_scene.fbx(filepath=str(ROOT/'MenuQuarantine.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,bake_anim=False,axis_forward='-Z',axis_up='Y')
scene.world=bpy.data.worlds.new('QuarantineNight')
scene.world.color=(.08,.10,.13)
bpy.ops.object.camera_add(location=(14,-21,12))
cam=bpy.context.object
cam.rotation_euler=(Vector((0,7,3.6))-cam.location).to_track_quat('-Z','Y').to_euler()
cam.data.lens=42
scene.camera=cam
for pos,power,color in (((0,-5,14),2600,(.55,.7,1)),((2,8,11),1800,(1,.45,.18))):
    bpy.ops.object.light_add(type='AREA',location=pos)
    light=bpy.context.object
    light.data.energy=power
    light.data.color=color
    light.data.shape='DISK'
    light.data.size=9
    light.rotation_euler=(Vector((0,6,2))-light.location).to_track_quat('-Z','Y').to_euler()
scene.render.engine='CYCLES'
scene.cycles.samples=16
scene.render.resolution_x=1200
scene.render.resolution_y=760
scene.render.resolution_percentage=100
scene.render.filepath=str(ROOT/'MenuQuarantine.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'MenuQuarantine.blend'),copy=True)
bpy.context.window.scene=old_scene
result={'parts':len(records),'blend':str(ROOT/'MenuQuarantine.blend'),'fbx':str(ROOT/'MenuQuarantine.fbx')}
