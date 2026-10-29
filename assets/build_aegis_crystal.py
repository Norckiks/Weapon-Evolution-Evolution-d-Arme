import math
import os

import bpy
from mathutils import Vector

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "Modeles_a_importer", "Capacites")
BLEND = os.path.join(ROOT, "ability_motion", "AegisCrystal.blend")
FBX = os.path.join(OUT, "AegisCrystal.fbx")
PREVIEW = os.path.join(OUT, "AegisCrystal.png")
os.makedirs(OUT, exist_ok=True)
os.makedirs(os.path.dirname(BLEND), exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.name = "Aegis Crystal - Prism Guard"
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = 900
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = PREVIEW
scene.view_settings.view_transform = "AgX"

world = bpy.data.worlds.new("Midnight Navy")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.009, 0.014, 0.04, 1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.28
scene.world = world

def material(name, color, metallic=0.0, roughness=0.3, emission=None, strength=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1)
        bsdf.inputs["Emission Strength"].default_value = strength
    return mat

amethyst = material("01 • Amethyst enamel", (0.12, 0.045, 0.38), 0.22, 0.2)
violet = material("02 • Violet facets", (0.34, 0.12, 0.76), 0.18, 0.24)
blue = material("03 • Cold prism", (0.12, 0.38, 0.88), 0.28, 0.18)
shadow = material("04 • Obsidian facets", (0.025, 0.02, 0.09), 0.35, 0.22)
gold = material("05 • Antique gold", (0.9, 0.51, 0.12), 0.82, 0.23)
core_mat = material("06 • Luminous heart", (0.55, 0.3, 1.0), 0.08, 0.16, (0.37, 0.15, 1.0), 1.7)
materials = [amethyst, violet, blue, shadow, gold, core_mat]

root = bpy.data.objects.new("AegisCrystalRoot", None)
scene.collection.objects.link(root)
root.empty_display_type = "SPHERE"
root.empty_display_size = 0.1

def mesh_object(name, vertices, faces, face_materials, mat_slots):
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.clear()
    for mat in mat_slots:
        mesh.materials.append(mat)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    obj.parent = root
    for poly, idx in zip(mesh.polygons, face_materials):
        poly.material_index = idx
        poly.use_smooth = False
    return obj

def make_prism(name, sides, levels, slot_mats, alternating=True, phase=0.0, open_faces=None):
    vertices = []
    for z, radius in levels:
        for i in range(sides):
            angle = (math.tau * i / sides) + phase + (0.09 if len(vertices) // sides % 2 else 0)
            vertices.append((math.cos(angle) * radius, math.sin(angle) * radius, z))
    faces, face_mats = [], []
    for level in range(len(levels) - 1):
        for i in range(sides):
            if open_faces and i in open_faces:
                continue
            faces.append((level * sides + i, level * sides + (i + 1) % sides,
                          (level + 1) * sides + (i + 1) % sides, (level + 1) * sides + i))
            face_mats.append((i + level) % len(slot_mats) if alternating else 0)
    faces.append(tuple(range(sides - 1, -1, -1)))
    face_mats.append(min(1, len(slot_mats) - 1))
    faces.append(tuple((len(levels) - 1) * sides + i for i in range(sides)))
    face_mats.append(min(2, len(slot_mats) - 1))
    return mesh_object(name, vertices, faces, face_mats, slot_mats)

# Cut planes and alternating facet tones give the shell a readable silhouette at small scale.
shell = make_prism("Aegis_PrismShell", 8,
    [(-0.45, 0.018), (-0.34, 0.105), (-0.15, 0.17), (0.07, 0.17),
     (0.29, 0.105), (0.45, 0.014)], [amethyst, violet, blue, shadow], open_faces={6})
heart = make_prism("Aegis_LightCore", 6,
    [(-0.30, 0.012), (-0.20, 0.052), (0.07, 0.066), (0.34, 0.038), (0.41, 0.008)],
    [core_mat], alternating=False, phase=math.pi / 6)

def make_band(name, radius, z, width, minor, segments=12):
    verts, faces = [], []
    for outer_radius, height in ((radius + minor, z - width / 2), (radius + minor, z + width / 2),
                                 (radius - minor, z - width / 2), (radius - minor, z + width / 2)):
        for i in range(segments):
            angle = math.tau * i / segments + math.pi / 8
            verts.append((math.cos(angle) * outer_radius, math.sin(angle) * outer_radius, height))
    for i in range(segments):
        j = (i + 1) % segments
        faces.extend(((i, j, segments + j, segments + i),
                      (2 * segments + i, 3 * segments + i, 3 * segments + j, 2 * segments + j),
                      (segments + i, segments + j, 3 * segments + j, 3 * segments + i),
                      (i, 2 * segments + i, 2 * segments + j, j)))
    return mesh_object(name, verts, faces, [0] * len(faces), [gold])

make_band("Aegis_GoldCrown", 0.143, 0.245, 0.032, 0.009)
make_band("Aegis_GoldFoot", 0.126, -0.315, 0.036, 0.011)
make_band("Aegis_GoldWaist", 0.171, -0.105, 0.018, 0.007)

def make_rib(index):
    angle = math.tau * index / 8 + math.pi / 8
    points = [Vector((math.cos(angle) * 0.105, math.sin(angle) * 0.105, -0.32)),
              Vector((math.cos(angle) * 0.178, math.sin(angle) * 0.178, -0.14)),
              Vector((math.cos(angle) * 0.178, math.sin(angle) * 0.178, 0.07)),
              Vector((math.cos(angle) * 0.112, math.sin(angle) * 0.112, 0.25))]
    curve = bpy.data.curves.new("Aegis_RibCurve", "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 1
    curve.bevel_depth = 0.0065
    curve.bevel_resolution = 1
    spline = curve.splines.new("POLY")
    spline.points.add(len(points) - 1)
    for point, co in zip(spline.points, points):
        point.co = (*co, 1)
    obj = bpy.data.objects.new("Aegis_GoldRib_%02d" % index, curve)
    scene.collection.objects.link(obj)
    obj.parent = root
    obj.data.materials.append(gold)
    return obj

ribs = [make_rib(i) for i in range(8)]

# Six small studs break up the base ring and create a repeatable radial read.
for i in range(6):
    angle = math.tau * i / 6
    bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=4,
        radius=0.017, location=(math.cos(angle) * 0.14, math.sin(angle) * 0.14, -0.315))
    stud = bpy.context.object
    stud.name = "Aegis_Rivet_%02d" % i
    stud.parent = root
    stud.data.materials.append(gold)
    for poly in stud.data.polygons:
        poly.use_smooth = True

# A small in-Blender preview action shows the buoyant rotation used by the live Roblox orbit.
scene.frame_start, scene.frame_end, scene.render.fps = 1, 49, 24
for frame, z, turn, pulse in ((1, 0, 0, 1), (13, 0.025, 0.22, 1.035),
                              (25, 0, 0.5, 1), (37, -0.025, 0.78, 0.965), (49, 0, 1, 1)):
    root.location.z = z
    root.rotation_euler.z = math.tau * turn
    root.scale = (pulse, pulse, pulse)
    root.keyframe_insert(data_path="location", frame=frame)
    root.keyframe_insert(data_path="rotation_euler", frame=frame)
    root.keyframe_insert(data_path="scale", frame=frame)
def aim(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()

bpy.ops.object.camera_add(location=(1.2, -1.9, 1.05))
camera = bpy.context.object
camera.name = "PreviewCamera"
camera.data.type = "ORTHO"
camera.data.ortho_scale = 1.5
aim(camera, (0, 0, 0))
scene.camera = camera

for name, location, power, size, color in (
    ("Key • lavender", (1.4, -1.0, 1.8), 105, 1.4, (0.68, 0.52, 1.0)),
    ("Fill • cyan", (-1.1, -0.7, 0.35), 48, 1.2, (0.3, 0.7, 1.0)),
    ("Rim • gold", (0.1, 1.3, 1.2), 85, 0.8, (1.0, 0.47, 0.12)),
):
    bpy.ops.object.light_add(type="AREA", location=location)
    light = bpy.context.object
    light.name = name
    light.data.energy = power
    light.data.shape = "DISK"
    light.data.size = size
    light.data.color = color
    aim(light, (0, 0, 0))

scene.frame_set(1)
bpy.ops.wm.save_as_mainfile(filepath=BLEND)

curve_objects = [obj for obj in scene.objects if obj.type == "CURVE"]
if curve_objects:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in curve_objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = curve_objects[0]
    bpy.ops.object.convert(target="MESH")

mesh_objects = [obj for obj in scene.objects if obj.type == "MESH"]
bpy.ops.object.select_all(action="DESELECT")
for obj in mesh_objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = shell
bpy.ops.export_scene.fbx(filepath=FBX, use_selection=True, object_types={"MESH"},
    apply_unit_scale=True, apply_scale_options="FBX_SCALE_UNITS",
    axis_forward="-Z", axis_up="Y", add_leaf_bones=False, bake_anim=False)

bpy.ops.render.render(write_still=True)
result = {"blend": BLEND, "fbx": FBX, "preview": PREVIEW,
          "mesh_objects": len(mesh_objects),
          "faces": sum(len(obj.data.polygons) for obj in mesh_objects),
          "dimensions": [round(float(v), 4) for v in shell.dimensions],
          "action": root.animation_data.action.name if root.animation_data else None}
print("AEGIS_ASSET_RESULT=" + str(result))
