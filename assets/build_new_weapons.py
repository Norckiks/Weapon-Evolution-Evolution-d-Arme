import bpy, math, json, os
from mathutils import Vector

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'new_weapons')
os.makedirs(OUT, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.render.fps = 30
bpy.context.preferences.filepaths.save_version = 0

def material(name, rgb, metallic=0.0, roughness=.6):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*rgb, 1)
    m.use_nodes = True
    bs = m.node_tree.nodes.get('Principled BSDF')
    bs.inputs['Base Color'].default_value = (*rgb, 1)
    bs.inputs['Metallic'].default_value = metallic
    bs.inputs['Roughness'].default_value = roughness
    return m

steel = material('Acier usé', (.24, .29, .30), .78, .38)
edge = material('Tranchant poli', (.65, .69, .66), .85, .28)
dark = material('Caoutchouc sombre', (.045, .055, .05), .05, .83)
rust = material('Rouille', (.32, .115, .055), .35, .8)
wrap = material('Bande textile', (.31, .19, .12), 0, .9)
yellow = material('Peinture de sécurité', (.85, .49, .07), .22, .65)

def finish(o, name, mat, parent):
    o.name = name
    o.data.materials.append(mat)
    o.parent = parent
    return o

def box(name, loc, scale, mat, parent, bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod=o.modifiers.new('Bords usés', 'BEVEL'); mod.width=bevel; mod.segments=2
        bpy.context.view_layer.objects.active=o
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return finish(o,name,mat,parent)

def cylinder(name, loc, radius, depth, mat, parent, vertices=12, rotation=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rotation or (0,0,0))
    return finish(bpy.context.object,name,mat,parent)

def prism(name, points, depth, mat, parent):
    verts=[(x,y,z) for y in (-depth/2,depth/2) for x,z in points]
    n=len(points)
    faces=[tuple(reversed(range(n))), tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces); mesh.update()
    obj=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(obj)
    return finish(obj,name,mat,parent)

def root(name):
    o=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(o); return o

machete=root('Machete')
cylinder('Poignee', (0,0,0), .12,.68,dark,machete,12)
for i in range(6):
    cylinder('Ligature %02d'%i,(0,0,-.26+i*.105),.132,.042,wrap,machete,12)
cylinder('Pommeau', (0,0,-.36), .15,.11,steel,machete,12)
box('Garde',(.015,0,.36),(.36,.24,.10),rust,machete)
blade=[(-.10,.39),(-.09,1.65),(-.20,2.02),(.03,2.23),(.34,2.06),(.32,.64),(.19,.39)]
prism('Lame asymétrique',blade,.105,steel,machete)
prism('Fil poli',[(.19,.40),(.32,.64),(.34,2.06),(.24,2.13),(.245,.68),(.13,.40)],.11,edge,machete)
prism('Dos rouillé',[(-.10,.42),(-.09,1.65),(-.20,2.02),(-.12,2.07),(-.01,1.64),(-.01,.42)],.113,rust,machete)
for z in (.54,.73):
    cylinder('Rivet de lame',(0,-.067,z),.045,.026,yellow,machete,10,(math.pi/2,0,0))
for z in (.80,1.0,1.20):
    box('Marque de récupération',(-.045,-.060,z),(.09,.012,.025),edge,machete,.003)

hammer=root('Sledgehammer')
cylinder('Manche renforcé',(0,0,.72),.105,2.02,dark,hammer,12)
for i in range(8):
    cylinder('Bandage manche %02d'%i,(0,0,-.20+i*.12),.12,.055,wrap,hammer,12)
cylinder('Bout de manche',(0,0,-.32),.14,.12,steel,hammer,12)
cylinder('Collier inférieur',(0,0,1.48),.16,.12,yellow,hammer,12)
box('Tête forgée',(0,0,1.78),(1.05,.52,.53),steel,hammer,.075)
for x in (-.53,.53):
    box('Face de frappe',(x,0,1.78),(.13,.58,.59),edge,hammer,.035)
    box('Bande peinture',(x*.69,-.269,1.78),(.12,.018,.45),yellow,hammer,.005)
for x in (-.24,.24):
    for z in (1.65,1.91):
        cylinder('Boulon',(x,-.278,z),.045,.035,rust,hammer,10,(math.pi/2,0,0))
box('Renfort de tête',(0,-.275,1.78),(.15,.025,.43),dark,hammer,.01)

def animate(o, xpos, keys):
    o.rotation_mode='XYZ'
    for frame,loc,rot in keys:
        o.location=(xpos+loc[0],loc[1],loc[2]); o.rotation_euler=tuple(math.radians(v) for v in rot)
        o.keyframe_insert(data_path='location',frame=frame); o.keyframe_insert(data_path='rotation_euler',frame=frame)
    o.animation_data.action.name=o.name+'_Attack'

animate(machete,-1.0,[(1,(0,0,0),(0,0,0)),(5,(.2,0,.12),(-15,25,45)),(8,(-.32,-.18,-.1),(30,-38,-55)),(18,(0,0,0),(0,0,0))])
animate(hammer,1.0,[(1,(0,0,0),(0,0,0)),(10,(.05,0,.35),(-68,8,12)),(14,(-.08,-.2,-.2),(72,-5,-12)),(28,(0,0,0),(0,0,0))])
bpy.context.scene.frame_set(1)

def mesh_payload(root_obj):
    bpy.context.view_layer.update()
    vertices=[]; faces=[]; colors=[]
    inv=root_obj.matrix_world.inverted()
    for obj in list(root_obj.children):
        if obj.type!='MESH': continue
        obj.data.calc_loop_triangles()
        offset=len(vertices)
        for v in obj.data.vertices:
            co=inv @ obj.matrix_world @ v.co
            vertices.append([round(co.x,5),round(co.z,5),round(-co.y,5)])
        c=obj.data.materials[0].diffuse_color
        rgb=[round(float(c[i]),4) for i in range(3)]
        for tri in obj.data.loop_triangles:
            faces.append([offset+i+1 for i in tri.vertices]); colors.append(rgb)
    return {'vertices':vertices,'faces':faces,'colors':colors}

for obj in (machete,hammer):
    with open(os.path.join(OUT,obj.name+'.json'),'w',encoding='utf8') as f: json.dump(mesh_payload(obj),f,separators=(',',':'))
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for c in obj.children: c.select_set(True)
    bpy.context.view_layer.objects.active=obj
    bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,obj.name+'.fbx'),use_selection=True,add_leaf_bones=False,bake_anim=True,apply_unit_scale=True)

scene=bpy.context.scene
scene.name='Nouvelles armes - animation'
scene.frame_end=28
scene.render.engine='CYCLES'; scene.cycles.samples=32
scene.render.resolution_x=900; scene.render.resolution_y=900; scene.render.resolution_percentage=100
world=scene.world; world.color=(.08,.08,.08)
def aim(obj, target): obj.rotation_euler=(Vector(target)-obj.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(4,-7,3.5)); cam=bpy.context.object; cam.data.type='ORTHO'; cam.data.ortho_scale=4.4; aim(cam,(0,0,1)); scene.camera=cam
for pos,power,size in [((1,-4,5),900,5),((-4,-2,3),650,4),((2,3,4),1000,3)]:
    bpy.ops.object.light_add(type='AREA',location=pos); light=bpy.context.object; light.data.energy=power; light.data.shape='DISK'; light.data.size=size; aim(light,(0,0,1))
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'Armes.blend'))
scene.render.filepath=os.path.join(OUT,'Armes.png')
bpy.ops.render.render(write_still=True)
print('WEAPONS_DONE',OUT)
