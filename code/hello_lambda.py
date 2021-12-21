import os


def lambda_handler(event, context):
    return "{} from the Star Wars Team!".format(os.environ['greeting'])