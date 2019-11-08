"""
Author: David Crook
Copyright: Microsoft Corporation 2019
"""
from flask import Flask

def create_app():
    app = Flask(__name__)

    from admin_app.apis.views import views
    app.register_blueprint(views)

    from admin_app.apis.security import security
    app.register_blueprint(security)

    return app
