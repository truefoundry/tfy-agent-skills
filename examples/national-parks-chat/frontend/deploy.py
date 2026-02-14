import os
from dotenv import load_dotenv
load_dotenv()

from truefoundry.deploy import Service, Build, DockerFileBuild, LocalSource, Port, Resources

service = Service(
    name="parks-frontend",
    image=Build(
        build_source=LocalSource(local_build=False),
        build_spec=DockerFileBuild(dockerfile_path="Dockerfile"),
    ),
    ports=[
        Port(
            port=3000,
            protocol="TCP",
            expose=True,
            # TODO: Replace with your cluster's base domain (see references/cluster-discovery.md)
            host=os.environ.get("TFY_DEPLOY_HOST", "parks-app-<workspace>.example.truefoundry.cloud"),
            app_protocol="http",
        )
    ],
    resources=Resources(
        cpu_request=0.25, cpu_limit=0.5,
        memory_request=256, memory_limit=512,
        ephemeral_storage_request=1000, ephemeral_storage_limit=2000,
    ),
    replicas=1,
    env={
        # TODO: Replace with your backend's deployed URL
        "NEXT_PUBLIC_API_URL": "https://parks-api-<workspace>.example.truefoundry.cloud",
    },
)

WORKSPACE_FQN = os.environ.get("TFY_WORKSPACE_FQN")
if not WORKSPACE_FQN:
    raise SystemExit("Set TFY_WORKSPACE_FQN (e.g. 'cluster-id:workspace-name')")
service.deploy(workspace_fqn=WORKSPACE_FQN)
