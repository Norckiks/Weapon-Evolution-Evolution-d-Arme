"""Build a separate modular Blender environment; never touches the open Blender scene."""
import bpy, math, random, os, json
from mathutils import Vector
from pathlib import Path

random.seed(713)
ROOT = Path(__file__).resolve().parent / 'refuge_city_rework'
ROOT.mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for c in list(bpy.data.collections):
    if c.name != 'Collection': bpy.data.collections.remove(c)

def material(name, color, metallic=0, roughness=.8, emission=0):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Metallic'].default_value=metallic; p.inputs['Roughness'].default_value=roughness
    if emission:
        p.inputs['Emission Color'].default_value=(*color,1); p.inputs['Emission Strength'].default_value=emission
    return m

M={
 'asphalt':material('Asphalte humide',(.045,.055,.063),.05,.74),
 'concrete':material('Beton use',(.30,.30,.27),0,.94),
 'concrete_dark':material('Beton sombre',(.15,.17,.17),0,.95),
 'brick':material('Brique ancienne',(.26,.135,.105),0,.92),
 'rust':material('Acier rouille',(.24,.12,.075),.45,.82),
 'iron':material('Acier noir',(.07,.085,.09),.7,.65),
 'wood':material('Bois use',(.25,.17,.105),0,.92),
 'canvas':material('Bache militaire',(.19,.23,.16),0,.95),
 'glass':material('Vitres sombres',(.06,.12,.14),.45,.25),
 'paint':material('Peinture ivoire',(.72,.66,.48),0,.8),
 'yellow':material('Jaune signalisation',(.78,.48,.08),.1,.8),
 'red':material('Rouge alerte',(.45,.055,.035),.1,.85),
 'glow':material('Lumiere chaude',(.95,.49,.15),0,.5,2.5),
 'cyan':material('Lumiere froide',(.09,.55,.65),0,.45,2.0),
 'portal':material('Portail bleu',(.025,.24,.32),.3,.42,.35),
}

class Module:
    def __init__(self, name, collection):
        self.name=name; self.collection=collection; self.parts={}; self.labels=[]
    def add(self, mat, verts, faces):
        v,f=self.parts.setdefault(mat,([],[])); off=len(v); v.extend(verts); f.extend([tuple(off+i for i in face) for face in faces])
    def box(self, mat, x,y,z, sx,sy,sz):
        a,b,c=sx/2,sy/2,sz/2
        self.add(mat,[(x+i*a,y+j*b,z+k*c) for k in (-1,1) for j in (-1,1) for i in (-1,1)],[(0,2,3,1),(4,5,7,6),(0,1,5,4),(2,6,7,3),(0,4,6,2),(1,3,7,5)])
    def cyl(self, mat, x,y,z, radius, height, axis='Z', sides=12):
        v=[]
        for h in (-height/2,height/2):
            for i in range(sides):
                a=2*math.pi*i/sides; u=radius*math.cos(a); w=radius*math.sin(a)
                v.append((x+u,y+w,z+h) if axis=='Z' else ((x+h,y+u,z+w) if axis=='X' else (x+u,y+h,z+w)))
        f=[tuple(range(sides-1,-1,-1)),tuple(range(sides,2*sides))]
        f += [(i,(i+1)%sides,(i+1)%sides+sides,i+sides) for i in range(sides)]
        self.add(mat,v,f)
    def text(self, label,x,y,z,size=1):
        self.labels.append((label,x,y,z,size))
    def finish(self):
        objects=[]
        for key,(verts,faces) in self.parts.items():
            mesh=bpy.data.meshes.new(self.name+'_'+key); mesh.from_pydata(verts,[],faces); mesh.update()
            obj=bpy.data.objects.new(self.name+'_'+key,mesh); self.collection.objects.link(obj); obj.data.materials.append(M[key]); objects.append(obj)
        for label,x,y,z,size in self.labels:
            curve=bpy.data.curves.new(self.name+'_label','FONT'); curve.body=label; curve.align_x='CENTER'; curve.align_y='CENTER'; curve.size=size
            obj=bpy.data.objects.new(self.name+'_label',curve); self.collection.objects.link(obj)
            obj.location=(x,y,z); obj.rotation_euler=(math.pi/2,0,0); obj.data.materials.append(M['paint'])
            bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True); bpy.context.view_layer.objects.active=obj
            bpy.ops.object.convert(target='MESH'); objects.append(bpy.context.object)
        return objects

def collection(name):
    c=bpy.data.collections.new(name); bpy.context.scene.collection.children.link(c); return c
H=collection('REFUGE'); C=collection('VILLE'); exports={}
def finish(g): exports[g.name]=g.finish()
def crate(g,x,y,z=0,s=3):
    g.box('wood',x,y,z+s/2,s,s,s)
    for dx in (-s*.39,s*.39): g.box('iron',x+dx,y,z+s/2,.13,s+.1,s+.12)
    for dz in (.12,s-.12): g.box('iron',x,y,z+dz,s+.15,s+.1,.13)
def barrel(g,x,y,z=0):
    g.cyl('rust',x,y,z+1.4,.85,2.8); g.cyl('iron',x,y,z+.45,.9,.12); g.cyl('iron',x,y,z+2.35,.9,.12)
def lamp(g,x,y,mat='glow'):
    g.cyl('iron',x,y,5.2,.17,10.4); g.box('iron',x,y,10.3,2.2,.6,.3); g.box(mat,x,y,10.1,1.6,.45,.18)
def portal(g,x,y,accent):
    for dx in (-5,5):
        g.box('iron',x+dx,y,6,1.3,2,12); g.box('rust',x+dx,y-.15,6,.55,2.2,11.2)
        for h in (1.2,4,7,10): g.box('yellow',x+dx,y-1.13,h,.65,.08,.13)
    g.box('iron',x,y,12,11.3,2,1.4); g.box('concrete_dark',x,y,0.4,12.2,5,.8)
    g.box('portal',x,y,5.5,8.7,.22,10.3); g.box(accent,x,y-1.1,12,8,.15,.3)
    g.box('iron',x,y,14.1,11,.8,2.1); g.box('paint',x,y-.44,14.1,9.4,.1,1.2)
def tent(g,x,y):
    for dx in (-8,8):
        for dy in (-6,6): g.box('iron',x+dx,y+dy,3.5,.35,.35,7)
    g.box('canvas',x,y,7,18,14,.45); g.box('canvas',x,y+6.7,3.5,18,.3,6.7)
    for dx in (-6,-3,0,3,6): g.box('rust',x+dx,y,7.28,.12,13,.1)
    crate(g,x-5,y+2); crate(g,x+4,y+3,0,2.5); barrel(g,x+7,y-3)
def building(g,x,y,width,depth,floors,kind):
    height=floors*7
    # Separate bays produce an irregular skyline instead of a single sealed block.
    bay_heights=[]
    for j in range(5):
        drop=random.choice([0,0,0,1,1,2]) if floors>3 else random.choice([0,0,1])
        h=(floors-drop)*7; bay_heights.append(h)
        g.box(kind,x+(j-2)*width/5,y,h/2,width/5-.18,depth,h)
    for side in (-1,1):
        g.box('concrete',x+side*(width/2-.6),y,height/2,1.2,depth+1,height)
    for fl in range(floors):
        z=4+fl*7
        for j in range(-2,3):
            if z+2.5 > bay_heights[j+2]: continue
            xx=x+j*(width-6)/5
            for face in (-1,1):
                yy=y+face*depth/2
                g.box('iron',xx,yy+face*.14,z,4.1,.25,4.9)
                g.box('glass',xx,yy+face*.3,z,3.55,.12,4.3)
                g.box('concrete',xx,yy+face*.4,z-2.55,4.7,.9,.25)
                g.box('iron',xx,yy+face*.4,z,.12,.12,4.3)
                if (j+fl+floors)%4==0:
                    g.box('wood',xx,yy+face*.48,z+.5,4.1,.15,.35)
                    g.box('wood',xx,yy+face*.49,z-.5,4.1,.15,.35)
        for side in (-1,1):
            if z+2.5 > bay_heights[0 if side==-1 else 4]: continue
            for dy in (-depth*.27,0,depth*.27):
                g.box('iron',x+side*(width/2+.13),y+dy,z,.22,4.1,4.9)
                g.box('glass',x+side*(width/2+.26),y+dy,z,.08,3.55,4.3)
                g.box('concrete',x+side*(width/2+.38),y+dy,z-2.55,.8,4.7,.25)
        g.box('concrete',x,y-depth/2-.3,z+3,width+1,1,.4)
        g.box('concrete',x,y+depth/2+.3,z+3,width+1,1,.4)
    for j,h in enumerate(bay_heights):
        dx=(j-2)*width/5; g.box('concrete_dark',x+dx,y,h+.2,width/5,depth+.5,.4)
        if j%2==0:
            for k in range(3): g.box('rust',x+dx+(k-1)*2,y-depth/2,h+1.1,.3,.3,2.2)
    tallest=max(range(5),key=lambda i:bay_heights[i]); tx=x+(tallest-2)*width/5; th=bay_heights[tallest]
    g.box('iron',tx,y+depth*.1,th+1,3,3,2)
    for dx in (-1,0,1): g.box('rust',tx+dx*.8,y+depth*.1,th+2.05,.12,2.8,.1)
    g.box('iron',x-width*.45,y+depth/2+.4,height*.5,.3,.3,height)
    for z in range(3,int(bay_heights[0]),5): g.box('rust',x-width*.45,y+depth/2+.6,z,1.3,.4,.25)
    # Damaged balcony rails, pipes, patchwork boards and roof debris.
    for fl in range(1,floors):
        z=fl*7
        if z+4 < bay_heights[3]:
            g.box('concrete',x+width*.2,y+depth/2+2,z,width*.36,4,.4)
            for xx in (x+width*.04,x+width*.36): g.box('iron',xx,y+depth/2+3.7,z+1.7,.18,.18,3.4)
            g.box('iron',x+width*.2,y+depth/2+3.7,z+3.3,width*.33,.18,.18)
def shop(g,x,y,title):
    g.box('concrete',x,y,.3,22,18,.6)
    for dx in (-10,10):
        for dy in (-8,8): g.box('iron',x+dx,y+dy,5,.6,.6,10)
    g.box('canvas',x,y,10.4,23,19,.65)
    for dx in range(-9,10,3): g.box('rust',x+dx,y,10.77,.12,18,.1)
    g.box('wood',x,y+5,3,19,2,6); g.box('iron',x,y+5,6.2,20,3,.45)
    g.box('canvas',x,y+7.8,5,20,.3,9)
    g.box('iron',x,y-8.4,9,17,.7,3); g.text(title,x,y-8.8,9,1.5)
    for dx in (-7,-3,1,5):
        g.box('rust',x+dx,y+4.8,6.9,1.5,1.3,1.2)
    crate(g,x-7,y+1,0,2.1); barrel(g,x+8,y+1)
def car(g,x,y,bus=False):
    w=7 if not bus else 10; l=13 if not bus else 23; h=4 if not bus else 7
    g.box('rust',x,y,2.4,w,l,h); g.box('iron',x,y,1,w+1,l+1,.8)
    g.box('glass',x,y-l*.23,3.5 if not bus else 5.2,w-.8,.2,2 if not bus else 2.6)
    for dx in (-w/2,w/2):
        for dy in (-l*.32,l*.32):
            g.cyl('iron',x+dx,y+dy,1.2,1.6,.75,'X',16); g.cyl('concrete_dark',x+dx*1.05,y+dy,1.2,.9,.8,'X',12)
    if bus:
        for dy in (-7,-3,1,5,9):
            for dx in (-w/2-.02,w/2+.02): g.box('glass',x+dx,y+dy,5.4,.1,3,2)
        g.box('yellow',x,y,2.8,w+.08,l,.3)
    else: g.box('glass',x,y+l*.14,4.5,w-.8,l*.4,.16)

# Refuge ground and walkways. Blender X/Y correspond to Roblox X/Z.
g=Module('Refuge_01_Sol_et_place',H)
g.box('concrete_dark',16,273,-.45,240,176,.9); g.box('concrete',0,273,.05,24,174,.2)
for y in range(185,360,12): g.box('paint',0,y,.18,.6,4,.05)
for x in (-14,14):
    for y in range(190,350,18): g.box('yellow',x,y,.2,.35,7,.08)
for x in (-36,36):
    for y in (240,280,320): lamp(g,x,y)
finish(g)
g=Module('Refuge_02_Porte_Ville',H); portal(g,0,208,'glow')
for x in (-11,11):
    g.box('concrete',x,208,3,5,8,6); g.box('iron',x,208,7,5,8,2); g.box('glow',x,205,8,2,.2,1)
    for k in range(3): g.box('rust',x,204,1+k*1.6,4,.2,.3)
finish(g)
for i,(name,level) in enumerate([('Usine',5),('Laboratoire',12),('Port',20),('Centrale',28),('Metro',35),('Quarantaine',45),('Barrage',60),('Citadelle',80)]):
    x=(-85,-65,-45,-25)[i%4]; y=(300,350)[i//4]
    g=Module('Refuge_Portal_%02d_%s_Niv%s'%(i+1,name,level),H); portal(g,x,y,'glow' if i<2 else ('cyan' if i<5 else 'red'))
    g.text(name.upper(),x,y-.52,14.25,1 if len(name)>8 else 1.35); g.text('NIV '+str(level),x,y-.53,13.55,.65); finish(g)
g=Module('Refuge_03_Terminal',H)
for y in (300,350):
    g.box('concrete',-55,y+4,.3,88,22,.6)
    for x in (-96,-55,-14): g.box('iron',x,y+5,8,1.5,2,16)
    g.box('iron',-55,y+5,16.2,84,3,1.2)
    for x in range(-92,-17,6): g.box('rust',x,y+5,17,1.1,1,2)
    g.box('iron',-55,y+3,19,58,1,4); g.box('yellow',-55,y+2.45,18.1,56,.1,.18)
    g.text('EXPEDITIONS',-55,y+2.4,19,1.8)
finish(g)
for i,(x,y) in enumerate([(-49,257),(49,257),(76,292),(105,292)]):
    g=Module('Refuge_Abri_%02d'%(i+1),H); tent(g,x,y); finish(g)
for i,(x,y,label) in enumerate([(-45,225,'ATELIER'),(45,225,'ARMURERIE'),(-69,267,'PETS'),(69,267,'BOUTIQUE')]):
    g=Module('Refuge_Boutique_%02d_%s'%(i+1,label),H); shop(g,x,y,label); finish(g)
g=Module('Refuge_04_Vie_du_camp',H)
for x,y in [(-48,231),(48,231),(-55,311),(55,311)]: crate(g,x,y); barrel(g,x+5,y)
for x in (-90,90):
    for y in range(225,326,20):
        g.box('iron',x,y,3,.45,.45,6); g.box('rust',x,y+9,4,.2,18,.25); g.box('rust',x,y+9,1.5,.2,18,.25)
for x in (-82,82):
    g.box('iron',x,307,11,.6,.6,22)
    for z in (6,10,14,18): g.box('rust',x,307,z,7,.4,.3)
    g.box('iron',x,307,22,12,.5,.4); g.box('glow',x,307,22.5,1.3,1.3,1)
for x,y in [(-26,283),(26,283)]:
    g.box('wood',x,y,2.2,9,3,.6)
    for dx in (-3,3): g.box('iron',x+dx,y,1,.4,2,2)
    g.box('wood',x,y+1.4,4,9,.4,3)
for x,y in [(10,270),(-10,270)]:
    g.cyl('iron',x,y,.5,2,.9, sides=12); g.cyl('glow',x,y,1,1.2,1.2,sides=10)
finish(g)
g=Module('Refuge_Reference_Arene_PVP',H)
g.box('iron',130,326,.27,44,32,.4)
g.box('concrete_dark',55,326,.24,110,10,.08)
for y in (321,331): g.box('neon',61,y,.31,90,.14,.04)
for x in (108,152): g.box('red',x,326,.5,.3,32,.15)
for y in (310,342): g.box('red',130,y,.5,44,.3,.15)
for x in (110,150):
    for y in (312,340): g.cyl('iron',x,y,3,.3,6); g.box('glow',x,y,6,.8,.8,.8)
finish(g)

# Large city within the existing City zone (X -200..200, Y -270..30).
g=Module('Ville_01_Sol_et_avenue',C)
g.box('concrete_dark',0,-120,-.6,400,300,1.2); g.box('asphalt',0,-120,.04,42,300,.15)
g.box('asphalt',0,-65,.08,390,30,.16)
for y in range(-255,25,13): g.box('paint',0,y,.18,.6,6,.05)
for x in (-23,23): g.box('concrete',x,-120,.25,3,300,.45)
for x in range(-180,181,16):
    if abs(x)>24: g.box('paint',x,-65,.2,6,.55,.06)
finish(g)
for i,(x,y,f,kind) in enumerate([(-58,-5,4,'brick'),(58,-5,5,'concrete'),(-61,-110,5,'concrete'),(61,-110,4,'brick'),(-61,-207,3,'brick'),(61,-207,6,'concrete'),(-133,-5,4,'concrete'),(133,-5,3,'brick'),(-133,-110,5,'brick'),(133,-110,4,'concrete'),(-133,-207,6,'concrete'),(133,-207,4,'brick')]):
    g=Module('Ville_Batiment_%02d'%(i+1),C); building(g,x,y,42,38,f,kind); finish(g)
g=Module('Ville_02_Checkpoint',C)
for x in (-16,16):
    g.box('concrete',x,17,4,5,5,8); g.box('iron',x,17,9,4,5,2)
g.box('iron',0,17,11,37,2,2); g.box('red',0,15.9,11,26,.2,.45)
car(g,-16,-15,True)
for x,y in [(14,-15),(18,-27),(-22,-36)]:
    g.box('concrete',x,y,1,5,2,2); g.box('yellow',x,y-1.05,1,4.4,.08,.25)
for x in (-26,26): lamp(g,x,-24,'cyan')
finish(g)
g=Module('Ville_03_Carrefour_et_pharmacie',C)
g.box('concrete',-58,-69,4,25,18,8); g.box('iron',-58,-78.2,8,26,1,1.8)
g.box('paint',-58,-78.75,8,20,.15,1); g.box('red',-58,-78.86,8,1.4,.12,2.5); g.box('red',-58,-78.87,8,3.5,.12,.6)
g.text('PHARMACIE',-58,-78.9,10,1.7)
for x in (-66,-61,-55,-50): g.box('wood',x,-78.4,4,2.5,.3,5.5); g.box('iron',x,-78.6,4,2.8,.2,.15)
car(g,29,-70); car(g,-31,-54)
for x,y in [(-33,-83),(32,-50),(46,-83)]: barrel(g,x,y)
for x,y in [(-40,-45),(41,-98)]: crate(g,x,y)
for x in (-26,26): lamp(g,x,-84,'cyan')
finish(g)
g=Module('Ville_04_Barricade_finale',C)
car(g,16,-224,True)
for x in (-25,-17,26,34):
    g.box('concrete',x,-235,1.5,7,4,3); g.box('yellow',x,-237.1,1.5,6,.1,.35)
for x in (-31,31): lamp(g,x,-215,'glow')
finish(g)
g=Module('Ville_05_Details_urbains',C)
for x in (-29,29):
    for y in (-35,-120,-160,-205,-250):
        lamp(g,x,y,'cyan')
        g.box('iron',x+(-4 if x<0 else 4),y+9,2,1,1,4)
for i in range(65):
    x=random.choice([-1,1])*random.uniform(28,180); y=random.uniform(-260,20)
    if abs(y+65)<20: continue
    g.box(random.choice(['concrete','concrete_dark','rust']),x,y,random.uniform(.1,.5),random.uniform(.4,2),random.uniform(.5,2),random.uniform(.15,.6))
finish(g)

# Export separately so every mesh stays below the platform triangle limit.
export_dir=ROOT/'fbx_modules'; export_dir.mkdir(exist_ok=True)
for name,objects in exports.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects: obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.export_scene.fbx(filepath=str(export_dir/(name+'.fbx')),use_selection=True,object_types={'MESH'},
        apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',add_leaf_bones=False)

scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=16
scene.render.resolution_x=1400; scene.render.resolution_y=950; scene.render.resolution_percentage=100
scene.world.color=(.42,.42,.42)
scene.world.use_nodes=True; scene.world.node_tree.nodes['Background'].inputs['Color'].default_value=(.24,.28,.34,1)
scene.world.node_tree.nodes['Background'].inputs['Strength'].default_value=.65
scene.view_settings.view_transform='AgX'
def point_camera(loc,target,scale):
    bpy.ops.object.camera_add(location=loc); cam=bpy.context.object; cam.name='Camera vue generale'
    cam.rotation_euler=(Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler(); cam.data.type='ORTHO'; cam.data.ortho_scale=scale; scene.camera=cam
def area_light(name,loc,energy,size,color,target):
    bpy.ops.object.light_add(type='AREA',location=loc); obj=bpy.context.object; obj.name=name
    obj.data.energy=energy; obj.data.shape='DISK'; obj.data.size=size; obj.data.color=color
    obj.rotation_euler=(Vector(target)-obj.location).to_track_quat('-Z','Y').to_euler()
area_light('Lune de presentation',(50,0,260),130000,240,(.60,.72,1),(0,0,0))
area_light('Remplissage de presentation',(-100,300,120),65000,180,(1,.65,.34),(0,250,0))
point_camera((300,65,240),(0,265,0),310)
C.hide_render=True; H.hide_render=False
scene.render.image_settings.file_format='PNG'; scene.render.filepath=str(ROOT/'Apercu_Refuge.png'); bpy.ops.render.render(write_still=True)
C.hide_render=False; H.hide_render=True
scene.camera.location=(410,-500,350); scene.camera.rotation_euler=(Vector((0,-120,0))-scene.camera.location).to_track_quat('-Z','Y').to_euler(); scene.camera.data.ortho_scale=520
scene.render.filepath=str(ROOT/'Apercu_Ville.png'); bpy.ops.render.render(write_still=True)
H.hide_render=False; C.hide_render=False
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'Refuge_et_Ville.blend'))
manifest={'coordinate_note':'Blender X/Y/Z correspond to Roblox X/Z/Y before importer axis conversion. Positions are design references, not validated Studio placements. Refuge_Reference_Arene_PVP is a reference of the existing arena, not a replacement.',
 'modules':[{'name':n,'objects':len(o),'vertices':sum(len(x.data.vertices) for x in o),'triangles':sum(len(p.vertices)-2 for x in o for p in x.data.polygons)} for n,o in exports.items()]}
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf8')
print('DONE modules=',len(exports),'mesh_objects=',sum(len(v) for v in exports.values()))
