import os
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '..', '.env'))

# The TrueFoundry SDK expects TFY_HOST, but our .env uses TFY_BASE_URL
if not os.environ.get("TFY_HOST") and os.environ.get("TFY_BASE_URL"):
    os.environ["TFY_HOST"] = os.environ["TFY_BASE_URL"]

from truefoundry.deploy import Service, Build, DockerFileBuild, LocalSource, Port, Resources

service = Service(
    name="nextjs-app",
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
            host=os.environ.get("TFY_DEPLOY_HOST", "nextjs-app-<workspace>.example.truefoundry.cloud"),
            app_protocol="http",
        )
    ],
    resources=Resources(
        cpu_request=0.25, cpu_limit=0.5,
        memory_request=256, memory_limit=512,
        ephemeral_storage_request=1000, ephemeral_storage_limit=2000,
    ),
    replicas=1,
)

WORKSPACE_FQN = os.environ.get("TFY_WORKSPACE_FQN")
if not WORKSPACE_FQN:
    raise SystemExit("Set TFY_WORKSPACE_FQN (e.g. 'cluster-id:workspace-name')")
service.deploy(workspace_fqn=WORKSPACE_FQN)
