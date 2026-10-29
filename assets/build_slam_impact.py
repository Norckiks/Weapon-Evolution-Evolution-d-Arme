import math
import random
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
BLEND = ROOT / "assets/ability_motion/SlamImpactStudy.blend"
OUT = ROOT / "assets/Modeles_a_importer/Capacites/SlamImpact"
FBX = OUT / "SlamImpact.fbx"
PREVIEW = OUT / "SlamImpact.png"


def material(name, color, metallic=0.0, roughness=0.4, emission=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    for key in ("Emission Color", "Emission"):
        if key in shader.inputs:
            shader.inputs[key].default_value = (*color, 1.0)
            break
    if "Emission Strength" in shader.inputs:
        shader.inputs["Emission Strength"].default_value = emission
    return mat


def make_mesh(name, vertices, faces, mat, bevel=0.0):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    collection.objects.link(obj)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("Soft chipped edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        modifier.limit_method = "ANGLE"
    return obj


def ring_plate(index, count, mat):
    step = math.tau / count
    a0 = index * step + 0.035
    a1 = (index + 1) * step - 0.035
    inner = 1.12 + random.uniform(-0.08, 0.08)
    outer0 = 3.05 + random.uniform(-0.28, 0.24)
    outer1 = 3.05 + random.uniform(-0.25, 0.3)
    z0 = random.uniform(-0.02, 0.02)
    z1 = random.uniform(-0.01, 0.04)
    points = [
        (inner * math.cos(a0), inner * math.sin(a0), z0),
        (outer0 * math.cos(a0), outer0 * math.sin(a0), z0),
        (outer1 * math.cos(a1), outer1 * math.sin(a1), z1),
        (inner * math.cos(a1), inner * math.sin(a1), z1),
    ]
    bottom = [(x, y, z - 0.22) for x, y, z in points]
    vertices = points + bottom
    faces = [(0, 1, 2, 3), (7, 6, 5, 4)]
    faces += [(i, (i + 1) % 4, (i + 1) % 4 + 4, i + 4) for i in range(4)]
    obj = make_mesh(f"Slam_CraterPlate_{index + 1:02}", vertices, faces, mat, 0.045)
    obj.rotation_euler.z = random.uniform(-0.08, 0.08)
    return obj


def crack(index, angle, mat, branch=False):
    curve = bpy.data.curves.new(f"Slam_MoltenCrack_{index:02}", "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 1
    curve.bevel_depth = 0.045 if not branch else 0.028
    curve.bevel_resolution = 2
    spline = curve.splines.new("POLY")
    points = 5 if not branch else 3
    spline.points.add(points - 1)
    start = random.uniform(0.9, 1.55) if not branch else random.uniform(1.8, 2.5)
    end = random.uniform(3.5, 4.65) if not branch else random.uniform(2.8, 3.7)
    for j, point in enumerate(spline.points):
        radius = start + (end - start) * j / (points - 1)
        a = angle + (0 if j in (0, points - 1) else random.uniform(-0.22, 0.22))
        z = 0.05 + (0.025 if j % 2 else 0)
        point.co = (radius * math.cos(a), radius * math.sin(a), z, 1)
    obj = bpy.data.objects.new(f"Slam_MoltenCrack_{index:02}", curve)
    collection.objects.link(obj)
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj.select_set(False)
    return obj


def add_shard(index, angle, rock, ember):
    radius = random.uniform(2.2, 3.25)
    point = Vector((radius * math.cos(angle), radius * math.sin(angle), 0.13))
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1, location=point)
    obj = bpy.context.object
    obj.name = f"Slam_ObsidianShard_{index:02}"
    obj.scale = (random.uniform(0.13, 0.24), random.uniform(0.16, 0.28), random.uniform(0.36, 0.72))
    obj.rotation_euler = (random.uniform(-0.35, 0.35), random.uniform(-0.35, 0.35), angle + random.uniform(-0.4, 0.4))
    obj.data.materials.append(ember if index % 3 == 0 else rock)
    return obj


def aim(obj, point):
    obj.rotation_euler = (Vector(point) - obj.location).to_track_quat("-Z", "Y").to_euler()


random.seed(27)
bpy.ops.wm.read_factory_settings(use_empty=False)
scene = bpy.context.scene
for obj in list(bpy.data.objects):
    bpy.data.objects.remove(obj, do_unlink=True)
scene.frame_start = 1
scene.frame_end = 18
scene.render.fps = 30
scene.unit_settings.system = "NONE"

collection = bpy.data.collections.new("Slam Impact | import meshes")
scene.collection.children.link(collection)
def find_layer(layer, target):
    if layer.collection == target:
        return layer
    for child in layer.children:
        found = find_layer(child, target)
        if found:
            return found
    return None
bpy.context.view_layer.active_layer_collection = find_layer(bpy.context.view_layer.layer_collection, collection)
root = bpy.data.objects.new("SlamImpactRoot", None)
collection.objects.link(root)

rock = material("Basalt | midnight blue", (0.028, 0.055, 0.085), 0.62, 0.3)
rock_light = material("Basalt | chipped edge", (0.11, 0.16, 0.19), 0.42, 0.34)
amber = material("Molten amber", (1.0, 0.31, 0.055), 0.25, 0.26, 2.2)
gold = material("Hot gold", (1.0, 0.77, 0.2), 0.1, 0.25, 1.7)

for i in range(12):
    ring_plate(i, 12, rock if i % 3 else rock_light)

bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1, location=(0, 0, 0.09))
core = bpy.context.object
core.name = "Slam_ImpactCore"
core.scale = (1.0, 1.0, 0.18)
core.data.materials.append(amber)

bpy.ops.mesh.primitive_torus_add(major_radius=3.28, minor_radius=0.055, major_segments=64, minor_segments=8, location=(0, 0, 0.02))
ring = bpy.context.object
ring.name = "Slam_EnergyRim"
ring.data.materials.append(gold)

for i in range(12):
    angle = math.tau * i / 12 + random.uniform(-0.07, 0.07)
    crack(i + 1, angle, amber)
    if i % 2 == 0:
        crack(i + 13, angle + random.choice((-1, 1)) * 0.24, gold, True)
    add_shard(i + 1, angle, rock_light, amber)

for obj in [o for o in collection.objects if o.type == "MESH"]:
    obj.parent = root
    obj.matrix_parent_inverse = root.matrix_world.inverted()
    obj.select_set(False)

root.scale = (0.22, 0.22, 0.22)
root.keyframe_insert(data_path="scale", frame=1)
root.scale = (1.0, 1.0, 1.0)
root.keyframe_insert(data_path="scale", frame=5)
root.scale = (1.12, 1.12, 1.12)
root.keyframe_insert(data_path="scale", frame=8)
root.scale = (1.08, 1.08, 1.08)
root.keyframe_insert(data_path="scale", frame=18)
if root.animation_data and root.animation_data.action:
    root.animation_data.action.name = "SlamImpact_PopAndSettle"

for obj in collection.objects:
    obj.hide_render = False
scene.frame_set(6)

camera_data = bpy.data.cameras.new("SlamPreviewCamera")
camera = bpy.data.objects.new("SlamPreviewCamera", camera_data)
scene.collection.objects.link(camera)
camera.location = (7.2, -9.0, 10.5)
camera.data.lens = 54
aim(camera, (0, 0, 0))
scene.camera = camera

light_data = bpy.data.lights.new("SlamKeyLight", "AREA")
light = bpy.data.objects.new("SlamKeyLight", light_data)
scene.collection.objects.link(light)
light.location = (1, -3, 8)
light.data.energy = 1700
light.data.shape = "DISK"
light.data.size = 8
aim(light, (0, 0, 0))

scene.world.color = (0.015, 0.022, 0.035)
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = 900
scene.render.resolution_y = 760
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False
scene.render.filepath = str(PREVIEW)
OUT.mkdir(parents=True, exist_ok=True)
BLEND.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND))

for obj in bpy.context.selected_objects:
    obj.select_set(False)
for obj in collection.objects:
    if obj.type == "MESH":
        world = obj.matrix_world.copy()
        obj.parent = None
        obj.matrix_world = world
        obj.select_set(True)
bpy.ops.export_scene.fbx(
    filepath=str(FBX),
    use_selection=True,
    object_types={"MESH"},
    axis_forward="-Z",
    axis_up="Y",
    apply_unit_scale=True,
    bake_anim=False,
)

result = {
    "blender_version": bpy.app.version_string,
    "blend": str(BLEND),
    "fbx": str(FBX),
    "preview": str(PREVIEW),
    "mesh_objects": sum(obj.type == "MESH" for obj in collection.objects),
    "polygons": sum(len(obj.data.polygons) for obj in collection.objects if obj.type == "MESH"),
    "animation": root.animation_data.action.name if root.animation_data else None,
    "frames": [1, 5, 8, 18],
}
