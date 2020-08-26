import subprocess

import os

TERRAFORM_DIR_PATH = os.path.dirname(os.path.realpath(__file__)) + "/../terraform/"


def terraform_init():
    """Terraform init command"""
    tf_init = ["terraform", "init", TERRAFORM_DIR_PATH]
    subprocess.check_call(tf_init)


def create_resources():
    """Create a tf resource."""
    proc = subprocess.Popen("terraform apply -auto-approve " + TERRAFORM_DIR_PATH, shell=True)
    proc.wait()


def destroy_resources():
    """Destroy all tf resources.

    This method will destroy any resources it can find in the state file,
    and delete all resources from the state file.
    """
    tf_destroy = [
        "terraform",
        "destroy",
        "-auto-approve",
        TERRAFORM_DIR_PATH
    ]
    subprocess.call(tf_destroy)

    tf_refresh = [
        "terraform",
        "refresh",
        TERRAFORM_DIR_PATH
    ]
    subprocess.call(tf_refresh)


def terraform_start():
    """ teardown and create resources at the beginning of feature test """
    terraform_init()
    destroy_resources()
    return create_resources()
