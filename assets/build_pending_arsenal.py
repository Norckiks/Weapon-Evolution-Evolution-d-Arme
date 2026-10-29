"""Build the pending melee arsenal in an isolated Blender process."""
import bpy, math, os, json
from mathutils import Vector

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Modeles_a_importer', 'Armes')
os.makedirs(OUT, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version = 0

def mat(name, color, metal=0.0, rough=.7):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Metallic'].default_value=metal; p.inputs['Roughness'].default_value=rough
    return m

def srgb_to_linear(value):
    value/=255
    return value/12.92 if value<=.04045 else ((value+.055)/1.055)**2.4

iron=mat('Acier sombre',(.12,.15,.17),.75,.48)
edge=mat('Tranchant',(.54,.60,.61),.8,.32)
leather=mat('Cuir use',(.16,.095,.057),.05,.9)
rust=mat('Rouille',(.33,.13,.06),.3,.85)
# Saturated silhouettes stay readable in the game's very dark refuge lighting.
colors=[(235,90,24),(0,150,145),(120,190,35),(218,35,42),(190,90,20),(0,160,115),(240,50,65),(30,150,235),(245,165,0),(235,75,25),(15,145,105),(210,45,15),(20,125,170),(235,180,0),(45,150,230),(135,45,225)]
specs=[
 ('Hook','Crochet de quarantaine','hook'),('Kris','Kris du veilleur','kris'),
 ('Spear','Lance de rupture','spear'),('Cleaver','Couperet des digues','cleaver'),
 ('WarHammer','Marteau de siege','hammer'),('Pike','Pique des remparts','pike'),
 ('PhaseBlade','Lame du coeur','phase'),('MirrorAxe','Hache de verre','axe'),
 ('RelayLance','Lance du relais','relay'),('OrbitalSpear','Lance orbitale','orbit'),
 ('RiftCleaver','Fendoir des abysses','rift'),('ForgeMaul','Maillet du dernier jour','maul'),
 ('ConvoyEdge','Lame du dernier convoi','convoy'),('ArcPike','Pique de la grille','arc'),
 ('BlackoutEdge','Trancheuse du blackout','blackout'),('EclipseGlaive',"Glaive de l'eclipse",'glaive')]

def attach(o, root, name, material):
    o.name=name; o.data.materials.append(material); o.parent=root
    return o
def box(root,name,loc,size,material,bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        m=o.modifiers.new('Bords','BEVEL'); m.width=bevel; m.segments=2
        bpy.context.view_layer.objects.active=o; bpy.ops.object.modifier_apply(modifier=m.name)
    return attach(o,root,name,material)
def cylinder(root,name,loc,radius,depth,material,vertices=12,rotation=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=depth,location=loc,rotation=rotation)
    return attach(bpy.context.object,root,name,material)
def plate(root,name,points,thickness,material):
    n=len(points); verts=[(x,y,z) for y in (-thickness/2,thickness/2) for x,z in points]
    faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces); mesh.update()
    obj=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(obj)
    return attach(obj,root,name,material)

roots=[]; report=[]
for index,(ident,label,kind) in enumerate(specs):
    rgb=tuple(srgb_to_linear(c) for c in colors[index])
    accent=mat('Accent_'+ident,rgb,.08,.43)
    highlight=mat('AccentHighlight_'+ident,tuple(c*.62+.38 for c in rgb),.08,.4)
    root=bpy.data.objects.new(ident,None); bpy.context.collection.objects.link(root)
    long=kind in ('spear','pike','relay','orbit','arc','glaive')
    shaft=1.85 if long else 1.02
    cylinder(root,'Manche',(0,0,shaft/2-.35),.095,shaft,iron)
    cylinder(root,'Pommeau',(0,0,-.40),.14,.14,accent)
    for j in range(7): cylinder(root,'Bande_%02d'%j,(0,0,-.29+j*.085),.115,.042,leather)
    for z in (.36,shaft-.48): cylinder(root,'Collier',(0,0,z),.14,.085,edge)
    base=shaft-.32
    box(root,'Garde',(0,0,base),(.54,.20,.09),iron,.018)
    if kind=='hook':
        points=[(-.10,base),(-.14,base+1.12),(-.05,base+1.48),(.25,base+1.64),(.58,base+1.42),(.61,base+1.08),(.46,base+1.25),(.26,base+1.32),(.15,base+1.20),(.14,base)]
    elif kind=='kris':
        points=[(-.13,base),(-.22,base+.35),(-.08,base+.65),(-.2,base+.95),(-.08,base+1.28),(0,base+1.55),(.14,base+1.26),(.03,base+.96),(.17,base+.64),(.05,base+.34),(.13,base)]
    elif kind in ('spear','pike','relay','orbit','arc'):
        width={'spear':.24,'pike':.17,'relay':.24,'orbit':.27,'arc':.22}[kind]
        points=[(-width,base+.13),(-width*.7,base+.78),(0,base+1.35),(width*.7,base+.78),(width,base+.13),(0,base+.28)]
    elif kind in ('hammer','maul'):
        box(root,'Tete',(0,0,base+.45),(1.05,.48,.60),iron,.055)
        for s in (-1,1):
            box(root,'Face',(s*.55,0,base+.45),(.12,.53,.65),edge,.02)
            box(root,'Renfort',(s*.31,-.252,base+.45),(.11,.03,.5),accent,.01)
        points=[(-.15,base+.76),(0,base+1.10),(.15,base+.76)]
    elif kind in ('axe','rift'):
        points=[(-.13,base),(-.14,base+.55),(-.78,base+.86),(-.86,base+1.25),(-.63,base+1.45),(-.36,base+1.1),(.12,base+1.0),(.15,base)]
    elif kind=='glaive':
        points=[(-.14,base),(-.2,base+.46),(-.58,base+.9),(-.64,base+1.42),(-.38,base+1.74),(-.45,base+1.25),(-.10,base+.91),(.2,base+.52),(.15,base)]
    elif kind=='cleaver':
        points=[(-.19,base),(-.32,base+1.25),(.4,base+1.42),(.48,base+1.15),(.37,base+.08),(.15,base)]
    else:
        w={'phase':.31,'convoy':.29,'blackout':.38}[kind]
        points=[(-w*.5,base),(-w,base+.7),(-w*.7,base+1.45),(0,base+1.75),(w*.7,base+1.45),(w,base+.7),(w*.5,base)]
    plate(root,'Silhouette',points,.13,accent)
    plate(root,'Noyau',[(x*.53,base+(z-base)*.78) for x,z in points],.15,highlight)
    # Rivets and spine provide detail without external textures.
    for j in range(3):
        cylinder(root,'Rivet_%d'%j,(0,-.095,base+.14+j*.18),.032,.025,rust,10,(math.pi/2,0,0))
    if kind in ('relay','arc','orbit','phase','blackout'):
        for side in (-1,1):
            box(root,'Ailette',(side*.25,0,base+.34),(.28,.14,.075),accent,.012)
    bpy.ops.object.select_all(action='DESELECT'); root.select_set(True)
    for obj in root.children: obj.select_set(True)
    bpy.context.view_layer.objects.active=root
    path=os.path.join(OUT,ident+'.fbx')
    bpy.ops.export_scene.fbx(filepath=path,use_selection=True,object_types={'EMPTY','MESH'},apply_unit_scale=True,
                             axis_forward='-Z',axis_up='Y',bake_anim=False,add_leaf_bones=False)
    triangles=0; max_mesh=0
    for obj in root.children:
        obj.data.calc_loop_triangles(); count=len(obj.data.loop_triangles); triangles+=count; max_mesh=max(max_mesh,count)
    assert triangles>0 and max_mesh<=20000
    report.append({'id':ident,'name':label,'file':ident+'.fbx','meshes':len(root.children),'triangles':triangles,'max_triangles_per_mesh':max_mesh})
    roots.append(root)

# Arrange only the source scene after exporting so all FBX grips stay at the origin.
for i,root in enumerate(roots): root.location=((i%4-1.5)*3.2,0,-(i//4)*4.2)
bpy.ops.object.camera_add(location=(0,-28,-5.6),rotation=(math.pi/2,0,0))
camera=bpy.context.object; camera.name='Apercu arsenal'; camera.data.type='ORTHO'; camera.data.ortho_scale=18
bpy.context.scene.camera=camera
bpy.ops.object.light_add(type='AREA',location=(0,-10,3)); light=bpy.context.object; light.data.energy=3000; light.data.shape='DISK'; light.data.size=15
light.rotation_euler=(Vector((0,0,-6))-light.location).to_track_quat('-Z','Y').to_euler()
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=24
scene.view_settings.view_transform='Standard'
scene.render.resolution_x=1400; scene.render.resolution_y=1400; scene.render.resolution_percentage=100
scene.world.color=(.12,.12,.12); scene.render.image_settings.file_format='PNG'
scene.render.filepath=os.path.join(OUT,'Apercu_arsenal.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'Arsenal.blend'))
bpy.ops.render.render(write_still=True)
with open(os.path.join(OUT,'manifest.json'),'w',encoding='utf-8') as f: json.dump(report,f,ensure_ascii=False,indent=2)
print('ARSENAL_OK',len(report),sum(x['triangles'] for x in report))
