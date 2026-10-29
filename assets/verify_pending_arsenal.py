"""Round-trip every arsenal FBX and prepare one real mesh for Studio import."""
import bpy, json, math, os

folder=os.path.join(os.path.dirname(os.path.abspath(__file__)),'Modeles_a_importer','Armes')
manifest=json.load(open(os.path.join(folder,'manifest.json'),encoding='utf-8'))
results=[]
for item in manifest:
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.fbx(filepath=os.path.join(folder,item['file']))
    bpy.context.view_layer.update()
    vertices=[]; faces=[]; meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    for obj in meshes:
        mesh=obj.data; mesh.calc_loop_triangles(); offset=len(vertices)
        for v in mesh.vertices:
            p=obj.matrix_world @ v.co
            vertices.append([round(p.x,6),round(p.z,6),round(-p.y,6)])
        for t in mesh.loop_triangles: faces.append([offset+i+1 for i in t.vertices])
    assert meshes and vertices and faces and all(math.isfinite(v) for p in vertices for v in p)
    assert len(faces)<20000 and len(vertices)<60000
    accent=next((m for o in meshes for m in o.data.materials if m and m.name.startswith('Accent_'+item['id'])),None)
    assert accent, f"{item['id']} is missing its weapon-color material after FBX roundtrip"
    accent_color=[round(v,6) for v in accent.diffuse_color[:3]]
    assert max(accent_color)-min(accent_color)>.25, f"{item['id']} accent material is too gray"
    bounds=[[min(p[i] for p in vertices),max(p[i] for p in vertices)] for i in range(3)]
    assert all(b[1]>b[0] for b in bounds)
    results.append({'id':item['id'],'meshes':len(meshes),'vertices':len(vertices),'triangles':len(faces),'bounds':bounds,'accentMaterial':accent.name,'accentColorLinear':accent_color})
    if item['id']=='Hook':
        with open(os.path.join(folder,'Hook_mesh_test.json'),'w') as f: json.dump({'vertices':vertices,'faces':faces},f,separators=(',',':'))
with open(os.path.join(folder,'verification.json'),'w',encoding='utf-8') as f: json.dump(results,f,ensure_ascii=False,indent=2)
print('ROUNDTRIP_OK',len(results))
