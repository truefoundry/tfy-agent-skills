import os
from dotenv import load_dotenv
load_dotenv()

from truefoundry.deploy import Service, Build, PythonBuild, LocalSource, Port, Resources

WORKSPACE_FQN = os.environ.get("TFY_WORKSPACE_FQN")
if not WORKSPACE_FQN:
    raise SystemExit("Set TFY_WORKSPACE_FQN (e.g. 'cluster-id:workspace-name')")

# TODO: Replace host with your cluster's base domain (see references/cluster-discovery.md)
HOST = os.environ.get("TFY_DEPLOY_HOST", "fastapi-app-<workspace>.example.truefoundry.cloud")

service = Service(
    name="fastapi-app",
    image=Build(
        build_source=LocalSource(local_build=False),
        build_spec=PythonBuild(
            python_version="3.11",
            command="uvicorn main:app --host 0.0.0.0 --port 8000",
            requirements_path="requirements.txt",
        ),
    ),
    ports=[
        Port(
            port=8000,
            protocol="TCP",
            expose=True,
            host=HOST,
            app_protocol="http",
        )
    ],
    resources=Resources(
        cpu_request=0.25, cpu_limit=0.5,
        memory_request=256, memory_limit=512,
        ephemeral_storage_request=1000, ephemeral_storage_limit=2000,
    ),
    replicas=1,
    env={},
)

service.deploy(workspace_fqn=WORKSPACE_FQN)
