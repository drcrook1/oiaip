"""
Author: David Crook
Copyright: Microsoft Corporation 2019
"""

from flask import Blueprint, render_template
import json

pack = Blueprint("pack", __name__, url_prefix='/api/v1')

@pack.route("/upload", methods=["POST"])
def upload():
    """
    Loads zip, parses zip.
    If IoT Hub and no iot hub exists, create.
    Deploy full infra etc; register everything etc.
    """
    result = {"something" : "some thing"}
    return json.dumps(result)