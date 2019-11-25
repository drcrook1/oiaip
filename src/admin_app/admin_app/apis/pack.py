"""
Author: David Crook
Copyright: Microsoft Corporation 2019
"""

from flask import Blueprint, render_template, abort, request
import json

pack = Blueprint("pack", __name__, url_prefix='/api/v1')

@pack.route("/register", methods=["POST"])
def register():
    """
    Loads zip, parses zip.
    If IoT Hub and no iot hub exists, create.
    Deploy full infra etc; register everything etc.
    """
    if("file" not in request.files):
        abort()"Must Specify File To Upload", 400)
    result = {"something" : "some thing"}
    return json.dumps(result)