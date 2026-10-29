import bpy
import math
import os
from mathutils import Vector

# Motion study only: this mannequin is not the Roblox character rig.
ROOT = r'C:\Users\Bruno\Documents\ChatGPT\Weapon Evolution\assets\ability_motion'
os.makedirs(ROOT, exist_ok=True)
old_scene = bpy.context.window.scene
scene = bpy.data.scenes.new('Ability motion study')
bpy.context.window.scene = scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.fps = 30
scene.render.resolution_x, scene.render.resolution_y = 1024, 1024
scene.world = bpy.data.worlds.new('Ability study world')
scene.world.color = (.12, .12, .12)

def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (*color, 1)
    return mat

body = material('Midnight suit', (.09, .14, .20))
skin = material('Mannequin skin', (.68, .46, .31))
accent = material('Warm accent', (.85, .48, .12))
arm_data = bpy.data.armatures.new('Study skeleton')
rig = bpy.data.objects.new('Ability study rig', arm_data)
scene.collection.objects.link(rig)
bpy.context.view_layer.objects.active = rig
rig.select_set(True)
bpy.ops.object.mode_set(mode='EDIT')
specs = {
    'Hips': ((0,0,1.0),(0,0,1.32),None),
    'Spine': ((0,0,1.32),(0,0,2.08),'Hips'),
    'Head': ((0,0,2.08),(0,0,2.45),'Spine'),
    'UpperArm.L': ((-.48,0,1.95),(-.54,0,1.48),'Spine'),
    'Forearm.L': ((-.54,0,1.48),(-.56,0,1.03),'UpperArm.L'),
    'UpperArm.R': ((.48,0,1.95),(.54,0,1.48),'Spine'),
    'Forearm.R': ((.54,0,1.48),(.56,0,1.03),'UpperArm.R'),
    'Thigh.L': ((-.23,0,1.05),(-.23,0,.55),'Hips'),
    'Shin.L': ((-.23,0,.55),(-.23,0,.08),'Thigh.L'),
    'Thigh.R': ((.23,0,1.05),(.23,0,.55),'Hips'),
    'Shin.R': ((.23,0,.55),(.23,0,.08),'Thigh.R'),
}
for name, (head, tail, parent) in specs.items():
    b = arm_data.edit_bones.new(name)
    b.head, b.tail = head, tail
    if parent:
        b.parent = arm_data.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT')

def segment(name, bone, center, dimensions, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel = obj.modifiers.new('Rounded edges', 'BEVEL')
    bevel.width, bevel.segments = .07, 3
    obj.modifiers.new('Normals', 'WEIGHTED_NORMAL')
    obj.data.materials.append(mat)
    group = obj.vertex_groups.new(name=bone)
    group.add(list(range(len(obj.data.vertices))), 1.0, 'REPLACE')
    mod = obj.modifiers.new('Skeleton', 'ARMATURE')
    mod.object = rig
    obj.parent = rig

segment('Torso', 'Spine', (0,0,1.68), (.82,.36,.74), body)
segment('Head mesh', 'Head', (0,0,2.29), (.42,.39,.42), skin)
segment('Pelvis', 'Hips', (0,0,1.17), (.68,.34,.28), body)
for s, x in [('L',-.54),('R',.54)]:
    segment('Upper arm '+s, 'UpperArm.'+s, (x,0,1.72), (.25,.30,.46), body)
    segment('Forearm '+s, 'Forearm.'+s, (x,0,1.25), (.22,.25,.43), skin)
    segment('Glove '+s, 'Forearm.'+s, (x,-.015,1.04), (.24,.27,.15), accent)
    x = -.23 if s == 'L' else .23
    segment('Thigh '+s, 'Thigh.'+s, (x,0,.80), (.28,.32,.48), body)
    segment('Shin '+s, 'Shin.'+s, (x,0,.32), (.25,.28,.46), body)
    segment('Boot '+s, 'Shin.'+s, (x,-.09,.10), (.28,.48,.17), accent)

# Values are local Euler rotations in degrees, at 30 fps. Each clip returns to rest.
poses = {
 'Pulse': [(1,{}),(8,{'UpperArm.L':(35,0,-25),'UpperArm.R':(35,0,25),'Forearm.L':(-65,0,0),'Forearm.R':(-65,0,0),'Spine':(-8,0,0)}),(13,{'UpperArm.L':(-75,0,20),'UpperArm.R':(-75,0,-20),'Forearm.L':(-15,0,0),'Forearm.R':(-15,0,0),'Spine':(12,0,0)}),(25,{})],
 'Slam': [(1,{}),(10,{'UpperArm.L':(-165,0,-12),'UpperArm.R':(-165,0,12),'Forearm.L':(-35,0,0),'Forearm.R':(-35,0,0),'Spine':(-18,0,0)}),(15,{'UpperArm.L':(-35,0,-10),'UpperArm.R':(-35,0,10),'Forearm.L':(-55,0,0),'Forearm.R':(-55,0,0),'Spine':(38,0,0)}),(34,{})],
 'Frost': [(1,{}),(9,{'UpperArm.L':(-45,0,-25),'UpperArm.R':(30,0,22),'Forearm.L':(-75,0,0),'Forearm.R':(-95,0,0),'Spine':(-8,12,0)}),(13,{'UpperArm.L':(-45,0,-25),'UpperArm.R':(-95,0,-10),'Forearm.L':(-55,0,0),'Forearm.R':(-12,0,0),'Spine':(8,-8,0)}),(31,{})],
 'Aegis': [(1,{}),(9,{'UpperArm.L':(-55,0,-42),'UpperArm.R':(-55,0,42),'Forearm.L':(-105,0,0),'Forearm.R':(-105,0,0)}),(15,{'UpperArm.L':(-88,0,-62),'UpperArm.R':(-88,0,62),'Forearm.L':(-20,0,0),'Forearm.R':(-20,0,0),'Spine':(-8,0,0)}),(35,{})],
 'SecondSouffle': [(1,{}),(12,{'UpperArm.L':(-30,0,-20),'UpperArm.R':(-30,0,20),'Forearm.L':(-105,0,0),'Forearm.R':(-105,0,0),'Spine':(12,0,0)}),(22,{'UpperArm.L':(-85,0,-45),'UpperArm.R':(-85,0,45),'Forearm.L':(-45,0,0),'Forearm.R':(-45,0,0),'Spine':(-10,0,0),'Head':(-10,0,0)}),(43,{})],
 'Arc': [(1,{}),(7,{'UpperArm.L':(-55,0,-35),'UpperArm.R':(20,0,28),'Forearm.L':(-80,0,0),'Forearm.R':(-110,0,0),'Spine':(-5,18,0)}),(11,{'UpperArm.L':(-50,0,-35),'UpperArm.R':(-100,0,-20),'Forearm.L':(-50,0,0),'Forearm.R':(-5,0,0),'Spine':(9,-14,0)}),(28,{})],
}
rig.animation_data_create()
for name, frames in poses.items():
    action = bpy.data.actions.new('Study '+name)
    rig.animation_data.action = action
    for frame, values in frames:
        for bone in rig.pose.bones:
            bone.rotation_mode = 'XYZ'
            bone.rotation_euler = tuple(math.radians(v) for v in values.get(bone.name, (0,0,0)))
            bone.keyframe_insert(data_path='rotation_euler', frame=frame, group=bone.name)
rig.animation_data.action = bpy.data.actions['Study Pulse']
scene.frame_start, scene.frame_end = 1, 43
scene.frame_set(13)
bpy.ops.object.camera_add(location=(4,-7,3.4))
camera = bpy.context.object
camera.name = 'Study camera'
camera.rotation_euler = (Vector((0,0,1.3))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 3.5
scene.camera = camera
bpy.ops.object.light_add(type='AREA', location=(2,-4,5))
bpy.context.object.data.energy = 600
bpy.context.object.data.size = 5
bpy.context.object.rotation_euler = (math.radians(35),0,math.radians(25))
for name, frames in poses.items():
    rig.animation_data.action = bpy.data.actions['Study '+name]
    for frame, _ in frames:
        scene.frame_set(frame)
        for bone in rig.pose.bones:
            assert all(math.isfinite(v) for v in bone.rotation_euler), (name, frame, bone.name)
    for frame in (frames[0][0], frames[-1][0]):
        scene.frame_set(frame)
        assert all(max(abs(v) for v in bone.rotation_euler) < .0001 for bone in rig.pose.bones), (name, frame)
rig.animation_data.action = bpy.data.actions['Study Pulse']
scene.frame_set(13)
scene.render.resolution_x = scene.render.resolution_y = 600
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = os.path.join(ROOT, 'PulseStudy.png')
bpy.ops.render.render(write_still=True)
path = os.path.join(ROOT, 'AbilityMotionStudy.blend')
bpy.ops.wm.save_as_mainfile(filepath=path, copy=True)
bpy.context.window.scene = old_scene
result = {'file':path,'actions':list(poses),'rig_bones':len(rig.pose.bones),'fps':scene.render.fps}
