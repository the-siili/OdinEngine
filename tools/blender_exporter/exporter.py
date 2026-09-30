bl_info = {
    "name": "azub Exporter",
    "author": "Your Name",
    "version": (1, 0, 0),
    "blender": (5, 2, 0),
    "location": "File > Export > azub",
    "description": "Exports selected mesh to a custom azub binary format",
    "category": "Import-Export",
}

import bpy
import struct

from bpy_extras.io_utils import ExportHelper
from bpy.props import StringProperty


def export_azub(filepath, obj):
    mesh = obj.data

    # Make sure we have evaluated mesh data.
    mesh.calc_loop_triangles()

    uv_layer = mesh.uv_layers.active
    # ------------------------------------------------------------
    # Collect vertices
    # ------------------------------------------------------------
    vertecies = []
    for tri in mesh.loop_triangles:

        for loop_index in tri.loops:

            loop = mesh.loops[loop_index]

            vertex_index = loop.vertex_index

            uv = uv_layer.data[loop_index].uv
            vertecies.append(mesh.vertices[vertex_index].co.x)
            vertecies.append(mesh.vertices[vertex_index].co.z)
            vertecies.append(mesh.vertices[vertex_index].co.y)
            vertecies.append(uv.x)
            vertecies.append(1.0-uv.y)
            vertecies.append(mesh.vertices[vertex_index].normal.x)
            vertecies.append(mesh.vertices[vertex_index].normal.z)
            vertecies.append(mesh.vertices[vertex_index].normal.y)
            print(
                "vertex:",
                vertex_index,
                "UV:",
                uv.x,
                uv.y
            )



    indexes = []
    for tri in mesh.loop_triangles:
        indexes.append(tri.loops[0])
        indexes.append(tri.loops[1])
        indexes.append(tri.loops[2])
    # ------------------------------------------------------------
    # Write binary azub file
    # ------------------------------------------------------------

    vertice_str = ""
    for v in vertecies:
        vertice_str += str(v)+","
    vertice_str = vertice_str[:-1]
    index_str = ""
    for v in indexes:
        index_str += str(v)+","
    index_str = index_str[:-1]

    with open(filepath, "w") as f:
        # Example header
        f.write(vertice_str+";"+index_str)

class EXPORT_OT_azub(bpy.types.Operator, ExportHelper):

    bl_idname = "export_scene.azub"
    bl_label = "Export azub"

    filename_ext = ".azub"

    filter_glob: StringProperty(
        default="*.azub",
        options={'HIDDEN'}
    )

    def execute(self, context):

        obj = context.active_object

        if obj is None:
            self.report(
                {'ERROR'},
                "No active object"
            )
            return {'CANCELLED'}

        if obj.type != 'MESH':
            self.report(
                {'ERROR'},
                "Active object is not a mesh"
            )
            return {'CANCELLED'}

        try:
            export_azub(self.filepath, obj)

        except Exception as e:
            self.report(
                {'ERROR'},
                str(e)
            )
            return {'CANCELLED'}

        self.report(
            {'INFO'},
            "azub export successful"
        )

        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(
        EXPORT_OT_azub.bl_idname,
        text="azub (.azub)"
    )


classes = (
    EXPORT_OT_azub,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)

    bpy.types.TOPBAR_MT_file_export.append(menu_func)


def unregister():
    bpy.types.TOPBAR_MT_file_export.remove(menu_func)

    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)


if __name__ == "__main__":
    register()
