"""
Author: David Crook
Copyright: Microsoft Corporation 2019
"""
from pymongo import MongoClient
import os
from kubernetes import client, config

def resolve_mongo_conn_string() -> str:
    """
    returns the mongo connection string for the currently deployed environment.
    """
    return os.environ["MONGO_CONN_STRING"]

def get_kube_client() -> client:
    """
    Returns the kube config
    """
    config_file = os.environ["KUBE_CONFIG_PATH"]
    config.load_kube_config(config_file=config_file)
    kube_client = client.CoreV1Api()
    return kube_client

def get_db_cxn() -> MongoClient:
    db = MongoClient(resolve_mongo_conn_string())
    return db
