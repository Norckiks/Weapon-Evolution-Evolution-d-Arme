import bpy, math, random, os
from mathutils import Vector

ROOT = r'C:\Users\Bruno\Documents\ChatGPT\Weapon Evolution\assets\city_zombies'
os.makedirs(ROOT, exist_ok=True)
random.seed(9041)
scene = bpy.data.scenes.new('City Zombies - sculpt and animation')
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x, scene.render.resolution_y, scene.render.resolution_percentage = 1500, 900, 100
scene.render.image_settings.file_format = 'PNG'
scene.world = bpy.data.worlds.new('Zombie studio world')
scene.world.color = (.075, .075, .075)
scene.render.film_transparent = False
scene.render.fps = 30
bpy.context.window.scene = scene

def material(name, color, rough=.82, metal=0):
    m = bpy.data.materials.new(name); m.diffuse_color = (*color, 1); m.use_nodes = True
    bs = m.node_tree.nodes.get('Principled BSDF'); bs.inputs['Base Color'].default_value = (*color, 1)
    bs.inputs['Roughness'].default_value = rough; bs.inputs['Metallic'].default_value = metal
    return m

SKIN = material('Skin - dead olive', (.24,.31,.20))
SKIN2 = material('Skin - pale infected', (.34,.37,.25))
SKIN3 = material('Skin - bloated grey green', (.26,.30,.20))
SHADOW = material('Wounds and sockets', (.075,.035,.035))
BLOOD = material('Dried blood', (.26,.045,.035))
BONE = material('Bone and teeth', (.67,.61,.42))
EYE = material('Cloudy infected eyes', (.83,.54,.18), .35)
BLACK = material('Hair and boots', (.075,.075,.065))
BLUE = material('Faded blue jacket', (.15,.20,.23))
RED = material('Torn oxblood hoodie', (.28,.09,.065))
GRAY = material('Torn work trousers', (.22,.22,.19))
LEATHER = material('Aged leather', (.20,.13,.085))
METAL = material('Rusty metal', (.28,.20,.13), .72, .5)
WRAP = material('Dirty bandages', (.49,.45,.34))

class MeshBuilder:
    def __init__(self): self.groups = {}
    def add(self, mat, bone, vertices, faces):
        group = self.groups.setdefault(mat.name, {'mat': mat, 'verts': [], 'faces': [], 'bones': {}})
        start = len(group['verts']); group['verts'].extend(vertices)
        group['faces'].extend([tuple(start+i for i in f) for f in faces])
        group['bones'].setdefault(bone, []).extend(range(start, start+len(vertices)))
    def ellipsoid(self, bone, mat, center, radius, detail=1, twist=0):
        seg, rings = (16, 10) if detail else (10, 7)
        verts, faces = [], []
        for j in range(rings+1):
            phi = math.pi*j/rings
            for i in range(seg):
                theta = 2*math.pi*i/seg
                rough = 1 + .022*math.sin(theta*3+phi*4+twist)*math.sin(phi)
                verts.append((center[0]+radius[0]*math.sin(phi)*math.cos(theta)*rough,
                              center[1]+radius[1]*math.sin(phi)*math.sin(theta)*rough,
                              center[2]+radius[2]*math.cos(phi)*rough))
        for j in range(rings):
            for i in range(seg):
                a=j*seg+i; b=j*seg+(i+1)%seg; faces.append((a,b,b+seg,a+seg))
        self.add(mat,bone,verts,faces)
    def limb(self, bone, mat, a, b, r1, r2, segments=12):
        a,b=Vector(a),Vector(b); axis=(b-a).normalized(); side=axis.cross(Vector((0,1,0)))
        if side.length<.01: side=axis.cross(Vector((1,0,0)))
        side.normalize(); other=axis.cross(side).normalized(); verts=[]; faces=[]
        for t,r in ((0,r1),(.32,r1*.96),(.72,r2*1.07),(1,r2)):
            for i in range(segments):
                ang=i*2*math.pi/segments; v=a.lerp(b,t)+(side*math.cos(ang)+other*math.sin(ang))*r*(1+.025*math.sin(i*3+t*5)); verts.append(tuple(v))
        for j in range(3):
            for i in range(segments):
                n=j*segments+i; k=j*segments+(i+1)%segments; faces.append((n,k,k+segments,n+segments))
        faces += [tuple(reversed(range(segments))),tuple(range(3*segments,4*segments))]
        self.add(mat,bone,verts,faces)
    def tear(self,bone,mat,center,width,height,seed):
        rng=random.Random(seed); x,y,z=center
        verts=[(x-width/2,y,z+height/2),(x+width/2,y,z+height/2)]
        for i in range(7): verts.append((x+width/2-width*i/6,y-.005*rng.random(),z-height/2+height*rng.uniform(-.16,.14)))
        self.add(mat,bone,verts,[tuple(range(len(verts)))])
    def build(self, rig, prefix):
        objects=[]
        for data in self.groups.values():
            mesh=bpy.data.meshes.new(prefix+' '+data['mat'].name); mesh.from_pydata(data['verts'],[],data['faces']); mesh.update()
            ob=bpy.data.objects.new(mesh.name,mesh); scene.collection.objects.link(ob); mesh.materials.append(data['mat'])
            for p in mesh.polygons: p.use_smooth=True
            for bone,indices in data['bones'].items(): ob.vertex_groups.new(name=bone).add(indices,1,'REPLACE')
            mod=ob.modifiers.new('Zombie skin','ARMATURE'); mod.object=rig; ob.parent=rig; objects.append(ob)
        return objects

def make_rig(name, wide, tall):
    data=bpy.data.armatures.new(name+' skeleton'); rig=bpy.data.objects.new(name+' Rig',data); scene.collection.objects.link(rig)
    bpy.context.view_layer.objects.active=rig; rig.select_set(True); bpy.ops.object.mode_set(mode='EDIT')
    specs=[('Hips',(0,0,1.45*tall),(0,0,1.75*tall),None),('Spine',(0,0,1.45*tall),(0,0,2.75*tall),'Hips'),('Head',(0,0,2.75*tall),(0,0,3.5*tall),'Spine')]
    for sign,label in ((-1,'L'),(1,'R')):
        x=sign*wide
        specs += [('UpperArm.'+label,(x*.64,0,2.55*tall),(x*.92,0,1.87*tall),'Spine'),('Forearm.'+label,(x*.92,0,1.87*tall),(x*1.02,0,1.19*tall),'UpperArm.'+label),('Hand.'+label,(x*1.02,0,1.19*tall),(x*1.02,-.03,.95*tall),'Forearm.'+label),('Thigh.'+label,(x*.31,0,1.5*tall),(x*.34,0,.84*tall),'Hips'),('Shin.'+label,(x*.34,0,.84*tall),(x*.36,0,.21*tall),'Thigh.'+label),('Foot.'+label,(x*.36,0,.21*tall),(x*.36,-.32,.12*tall),'Shin.'+label)]
    for n,head,tail,parent in specs:
        b=data.edit_bones.new(n); b.head=head; b.tail=tail
        if parent: b.parent=data.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT'); rig.select_set(False)
    return rig

def character(name,kind):
    wide,tall={'Rodeur':(1,1),'Affame':(.86,1.03),'Colosse':(1.35,1.12)}[name]
    skin={'Rodeur':SKIN,'Affame':SKIN2,'Colosse':SKIN3}[name]
    cloth={'Rodeur':BLUE,'Affame':RED,'Colosse':LEATHER}[name]
    rig=make_rig(name,wide,tall); g=MeshBuilder()
    e=g.ellipsoid; limb=g.limb; tear=g.tear
    e('Spine',skin,(0,0,2.15*tall),(.63*wide,.35, .77*tall))
    e('Spine',cloth,(0,.015,2.15*tall),(.66*wide,.395,.78*tall))
    e('Spine',skin,(0,0,2.81*tall),(.18,.17,.23*tall))
    e('Head',skin,(0,0,3.17*tall),(.37,.31,.48*tall))
    e('Head',skin,(0,-.15,2.96*tall),(.29,.23,.20*tall))
    # Deep eye sockets, asymmetric eyes, mouth cavity and exposed teeth face -Y.
    for s in (-1,1):
        e('Head',skin,(s*.36,0,3.13*tall),(.09,.08,.14*tall),0)
        e('Head',SHADOW,(s*.16,-.285,3.23*tall),(.13,.055,.11*tall),0)
        e('Head',EYE,(s*.16,-.337,3.23*tall),(.058,.026,.052*tall),0)
        e('Head',skin,(s*.16,-.31,3.34*tall),(.14,.045,.035*tall),0)
    e('Head',SHADOW,(0,-.293,2.98*tall),(.24,.07,.12*tall),0)
    e('Head',skin,(0,-.34,3.12*tall),(.075,.075,.10*tall),0)
    for i in range(5): e('Head',BONE,((i-2)*.075,-.365,3.00*tall),(.025,.025,.044*tall),0)
    for i in range(3): limb('Head',BLOOD,(.08+i*.055,-.31,3.44*tall),(.16+i*.055,-.31,3.30*tall),.012,.008,7)
    for i in range(7):
        x=-.25+i*.075
        e('Head',SHADOW,(x,-.286,3.02*tall+(.02 if i%2 else -.01)),(.018,.016,.025),0)
    for s,label in ((-1,'L'),(1,'R')):
        x=s*wide
        upper=(x*.72,0,2.43*tall); elbow=(x*.92,0,1.87*tall); wrist=(x*1.02,-.02,1.19*tall)
        e('UpperArm.'+label,cloth,upper,(.24*wide,.24,.34*tall),0)
        limb('UpperArm.'+label,skin,(x*.7,0,2.48*tall),elbow,.21*wide,.17*wide)
        limb('Forearm.'+label,skin,elbow,wrist,.16*wide,.13*wide)
        e('Hand.'+label,skin,(x*1.02,-.03,1.12*tall),(.15*wide,.14,.20*tall),0)
        for i in range(4):
            fx=x*1.02+(i-1.5)*.068*wide
            limb('Hand.'+label,skin,(fx,-.08,1.04*tall),(fx+s*.025,-.11,.84*tall),.035,.023,7)
            e('Hand.'+label,BONE,(fx+s*.025,-.11,.83*tall),(.024,.028,.04),0)
        for i in range(3):
            z=(1.32+i*.13)*tall
            limb('Forearm.'+label,BLOOD,(x*.98-.09,-.14,z),(x*.98+.06,-.15,z+.07*tall),.012,.008,7)
        hip=(x*.31,0,1.5*tall); knee=(x*.34,0,.84*tall); ankle=(x*.36,0,.21*tall)
        limb('Thigh.'+label,GRAY,hip,knee,.25*wide,.20*wide)
        limb('Shin.'+label,GRAY,knee,ankle,.19*wide,.14*wide)
        e('Foot.'+label,BLACK,(x*.36,-.15,.13*tall),(.19*wide,.34,.13*tall),0)
        for k in range(2): limb('Shin.'+label,WRAP,(x*.34-.12*wide,-.17,(.60-k*.1)*tall),(x*.34+.12*wide,-.17,(.67-k*.1)*tall),.018,.018,7)
    if kind=='civilian':
        for s in (-1,1):
            tear('Spine',BLUE,(s*.45,-.36,1.62*tall),.32,.42*tall,11+s)
            limb('Spine',LEATHER,(s*.44,-.37,2.65*tall),(s*.20,-.39,1.55*tall),.035,.032,8)
        e('Spine',LEATHER,(0,.36,2.05*tall),(.48,.24,.52*tall))
        limb('Spine',BONE,(-.16,-.385,2.14*tall),(.21,-.39,2.38*tall),.013,.013,7)
        for i in range(4): limb('Spine',BONE,(-.12+i*.085,-.405,2.16*tall),(-.09+i*.085,-.405,2.22*tall),.01,.01,7)
        for i in range(9): e('Head',BLACK,(-.30+i*.075,.01,3.51*tall),(.08,.25,.09),0,i)
        tear('Spine',GRAY,(-.29,-.405,2.38*tall),.36,.24*tall,104)
        for i in range(3): limb('Spine',BONE,(-.39+i*.08,-.417,2.43*tall),(-.35+i*.08,-.42,2.34*tall),.009,.009,7)
        tear('Forearm.R',WRAP,(wide*.96,-.17,1.50*tall),.27,.18*tall,42)
    elif kind=='runner':
        e('Head',SHADOW,(0,-.30,2.97*tall),(.27,.08,.16*tall),0)
        e('Head',RED,(0,.13,3.37*tall),(.40,.31,.39*tall))
        for s in (-1,1):
            e('Head',RED,(s*.31,-.06,3.20*tall),(.11,.23,.31*tall),0)
            for j in range(3): limb('Hand.'+('L' if s<0 else 'R'),BONE,(s*wide*1.02+(j-1)*.08,-.12,1.00*tall),(s*wide*1.02+(j-1)*.08,-.21,.72*tall),.035,.006,8)
        tear('Spine',SHADOW,(0,-.38,2.05*tall),.58,.66*tall,94)
        for i in range(4):
            for s in (-1,1): limb('Spine',BONE,(s*.04,-.405,(2.29-i*.13)*tall),(s*(.30-i*.03),-.41,(2.24-i*.13)*tall),.022,.012,8)
        for i in range(3): tear('Spine',RED,(-.32+i*.32,-.37,1.54*tall),.22,.43*tall,55+i)
    else:
        e('Head',skin,(0,-.09,2.96*tall),(.34,.25,.21*tall))
        for i in range(5):
            z=(2.50-i*.12)*tall
            limb('Spine',BLOOD,(-.45*wide,-.40,z),(-.23*wide,-.43,z+.08*tall),.017,.01,7)
        for s,label in ((-1,'L'),(1,'R')):
            e('UpperArm.'+label,skin,(s*wide*.72,.02,2.48*tall),(.36,.31,.33*tall))
            e('UpperArm.'+label,METAL,(s*wide*.71,.02,2.69*tall),(.39,.35,.14*tall))
            for i in range(3): e('UpperArm.'+label,BONE,(s*wide*(.50+i*.16),-.28,2.70*tall),(.035,.03,.035),0)
            e('Forearm.'+label,LEATHER,(s*wide*.97,0,1.44*tall),(.25,.24,.16*tall),0)
        limb('Spine',LEATHER,(-.48*wide,-.38,2.66*tall),(.42*wide,-.39,1.58*tall),.065,.055,10)
        e('Spine',METAL,(.12,-.39,2.13*tall),(.44,.09,.38*tall))
        for i in range(4): limb('Head',BLOOD,(.14+i*.04,-.30,3.43*tall),(.20+i*.04,-.33,3.28*tall),.014,.01,7)
        e('Head',BONE,(-.28,-.04,3.45*tall),(.10,.10,.22*tall),0)
    meshes=g.build(rig,name)
    return rig,meshes

def key(rig, bone, frame, xyz):
    p=rig.pose.bones[bone]; p.rotation_mode='XYZ'; p.rotation_euler=xyz; p.keyframe_insert(data_path='rotation_euler',frame=frame,group=bone)

def action(rig,name,kind,mode):
    rig.animation_data_create(); rig.animation_data.action=None
    act=bpy.data.actions.new(name+'_'+mode); rig.animation_data.action=act
    for p in rig.pose.bones: p.rotation_mode='XYZ'; p.rotation_euler=(0,0,0)
    if mode=='Idle':
        for f in (1,16,31):
            wave=0 if f!=16 else 1
            key(rig,'Spine',f,((.10 if kind=='runner' else .05)+.025*wave,0,(-.08 if kind=='civilian' else .03)*wave))
            key(rig,'Head',f,(-.07+.04*wave,.03*wave,(.17 if kind=='civilian' else -.05)*wave))
            for s,l in ((-1,'L'),(1,'R')): key(rig,'UpperArm.'+l,f,(-.18-.08*wave,0,-s*(.10 if kind!='brute' else .25)))
    elif mode=='Walk':
        for f in (1,7,13,19,25):
            wave=math.sin((f-1)*2*math.pi/24); bob=math.cos((f-1)*4*math.pi/24)
            key(rig,'Spine',f,((.24 if kind=='runner' else .08)+.035*bob,0,wave*(.16 if kind=='brute' else .07)))
            key(rig,'Head',f,(-.12+.05*bob,0,-wave*.08))
            for s,l in ((-1,'L'),(1,'R')):
                amp=.75 if kind=='runner' else .43 if kind=='civilian' else .34
                key(rig,'Thigh.'+l,f,(s*wave*amp,0,0)); key(rig,'Shin.'+l,f,(max(0,-s*wave)*amp*.55,0,0))
                key(rig,'UpperArm.'+l,f,(-.25-s*wave*amp*.48,0,-s*(.15 if kind=='brute' else .08)))
                key(rig,'Forearm.'+l,f,(-.25+max(0,s*wave)*.18,0,0))
    else:
        # Wind-up, strike and recovery match the server's telegraphed melee phases.
        for f,power in ((1,0),(10,-.35),(14,1),(24,.25),(31,0)):
            key(rig,'Spine',f,(.10+power*(.32 if kind=='brute' else .22),0,power*(.16 if kind=='runner' else .05)))
            key(rig,'Head',f,(-power*.16,0,-power*.08))
            for s,l in ((-1,'L'),(1,'R')):
                asym=.45 if kind=='civilian' and l=='L' else .7 if kind=='runner' and l=='L' else 1
                key(rig,'UpperArm.'+l,f,(-.25-power*(1.2 if kind=='brute' else 1.0)*asym,0,-s*(.18+power*.15)))
                key(rig,'Forearm.'+l,f,(-.3-power*(.35 if kind=='runner' else .18),0,0))
    return act

def export(rig,meshes,path,animated):
    bpy.ops.object.select_all(action='DESELECT'); rig.select_set(True)
    for ob in meshes: ob.select_set(True)
    bpy.context.view_layer.objects.active=rig
    bpy.ops.export_scene.fbx(filepath=path,use_selection=True,object_types={'ARMATURE','MESH'},apply_unit_scale=True,
        apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',add_leaf_bones=False,
        bake_anim=animated,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,bake_anim_force_startend_keying=True)

all_rigs=[]
for name,kind in [('Rodeur','civilian'),('Affame','runner'),('Colosse','brute')]:
    rig,meshes=character(name,kind); all_rigs.append((rig,meshes,kind))
    for mode in ('Idle','Walk','Attack'):
        action(rig,name,kind,mode); scene.frame_start=1; scene.frame_end=31 if mode!='Walk' else 25
        export(rig,meshes,os.path.join(ROOT,name+'_'+mode+'.fbx'),True)
    rig.animation_data.action=None; scene.frame_set(1)
    export(rig,meshes,os.path.join(ROOT,name+'_Rig.fbx'),False)
for i,(rig,meshes,kind) in enumerate(all_rigs): rig.location.x=(i-1)*2.8; rig.animation_data.action=bpy.data.actions[rig.name.replace(' Rig','')+'_Idle']
scene.frame_start=1; scene.frame_end=31; scene.frame_set(1)
def area(name,loc,energy,size,color):
    data=bpy.data.lights.new(name,'AREA'); data.energy=energy; data.shape='DISK'; data.size=size; data.color=color
    ob=bpy.data.objects.new(name,data); scene.collection.objects.link(ob); ob.location=loc; ob.rotation_euler=(Vector((0,0,1.9))-ob.location).to_track_quat('-Z','Y').to_euler()
area('Key',(-4,-6,8),850,5,(.82,.91,1)); area('Fill',(5,-3,5),600,4,(1,.66,.38)); area('Rim',(0,5,6),1100,4,(.52,.75,1))
camera_data=bpy.data.cameras.new('Zombie lineup camera'); camera=bpy.data.objects.new('Zombie lineup camera',camera_data); scene.collection.objects.link(camera)
camera.location=(7,-13,5.3); camera.rotation_euler=(Vector((0,0,1.8))-camera.location).to_track_quat('-Z','Y').to_euler(); camera_data.type='ORTHO'; camera_data.ortho_scale=10.5; scene.camera=camera
scene.view_settings.view_transform='AgX'
blend=os.path.join(ROOT,'CityZombies.blend'); bpy.ops.wm.save_as_mainfile(filepath=blend,copy=True)
scene.render.filepath=os.path.join(ROOT,'CityZombies.png'); bpy.ops.render.render(scene=scene.name,write_still=True)
print('Saved rigged zombies, FBX animations and render in',ROOT)
