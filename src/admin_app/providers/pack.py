"""
Author: David Crook
Copyright: Microsoft Corporation 2019
"""
from pymongo import MongoClient
import os
from enum import Enum

class DeployType(Enum):
    IOT = 1
    CLOUD = 2

class App():
    """
    Object Definition for an app running in the OIAIP
    """
    name : str = None
    path_in_pack : str = None
    deploy_type : DeployType = None

class CloudApp(App):
    """
    Cloud specific definition for an app running in OIAIP Cloud
    """
    deployed_namespace : str = None
    service_name : str = None
    public_endpoint : str = None

class Pack():
    """
    Object Definition for an industrial pack which can be loaded into the OIAIP.
    """
    name : str = None
    version : str = None
    industry : str = None
    deploy_type : DeployType = None
    admin_app : CloudApp = None
    stakeholer_app : CloudApp = None
    transform_app : App = None
    data_capture_app : App = None
    prediction_app : App = None
    ui_app : App = None
    telemetry_app : App = None

