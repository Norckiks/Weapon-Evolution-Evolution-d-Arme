"""Open the generated blend and re-import sample FBX files for a basic round trip."""
import bpy, math, json
from pathlib import Path

root=Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(root/'Refuge_et_Ville.blend'))
meshes=[o for o in bpy.data.objects if o.type=='MESH']
assert meshes and {'REFUGE','VILLE'} <= {c.name for c in bpy.data.collections}
assert all(math.isfinite(v.co[i]) for o in meshes for v in o.data.vertices for i in range(3))
manifest=json.loads((root/'manifest.json').read_text(encoding='utf8'))
assert len(manifest['modules'])==38
assert len([m for m in manifest['modules'] if m['name'].startswith('Refuge_Portal_')])==8
assert len([m for m in manifest['modules'] if m['name'].startswith('Ville_Batiment_')])==12
assert all((root/'fbx_modules'/(m['name']+'.fbx')).is_file() for m in manifest['modules'])
portal_bounds=[]
for o in meshes:
    if o.name.startswith('Refuge_Portal_'):
        portal_bounds.extend((o.matrix_world @ v.co).x for v in o.data.vertices)
assert max(portal_bounds)<26, 'Portal geometry reaches the existing arena X boundary'
max_triangles=max(sum(len(p.vertices)-2 for p in o.data.polygons) for o in meshes)
samples={}
for name in ['Refuge_Portal_01_Usine_Niv5','Ville_Batiment_06','Ville_02_Checkpoint']:
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.fbx(filepath=str(root/'fbx_modules'/(name+'.fbx')))
    imported=[o for o in bpy.context.scene.objects if o.type=='MESH']
    assert imported and sum(len(o.data.polygons) for o in imported)>0
    samples[name]={'mesh_objects':len(imported),'polygons':sum(len(o.data.polygons) for o in imported)}
result={'modules':len(manifest['modules']),'mesh_objects':len(meshes),'max_triangles_in_mesh':max_triangles,
        'portal_max_x':max(portal_bounds),'fbx_roundtrip_samples':samples}
(root/'verification.json').write_text(json.dumps(result,indent=2),encoding='utf8')
print('REFUGE_CITY_QA',json.dumps(result))
