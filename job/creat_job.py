from kubernetes import client, config
import yaml
import argparse

def create_job_object(pairs):
    job_name = "tandem-batch-job-rerun-2"
    k = len(pairs)
    command_script = 'items=('
    command_script += ' '.join([f'\'{pair1} {pair2}\'' for pair1, pair2 in pairs])
    command_script += ');'
    command_script += 'cd /home/tandem/storage/;'
    command_script += 'python3 run_sim.py ${items[${JOB_COMPLETION_INDEX}]} /home/tandem/storage/ /home/tandem/storage/gf/ /home/tandem/casc/casc.msh /home/tandem/casc/casc.lua /home/tandem/build_2d_6p/app/tandem /home/tandem/casc/solver.cfg'
    
    print(command_script)
    
    
    container = client.V1Container(
        name="tandem-container",
        image="yohaimagen1/tandem_v1.2:latest",
        image_pull_policy="Always",
        command=["bash", "-c", command_script],
        resources=client.V1ResourceRequirements(
            limits={"memory": "80Gi", "cpu": "50"},
            requests={"memory": "80Gi", "cpu": "30"},
        ),
        volume_mounts=[
            client.V1VolumeMount(
                mount_path="/home/tandem/storage", name="yohai-magen-sse-pvc"
            )
        ],
        env=[
            client.V1EnvVar(name="OPENMPI_ALLOW_RUN_AS_ROOT", value="1"),
            client.V1EnvVar(name="OMP_PROC_BIND", value="true"),
            client.V1EnvVar(name="OMP_PLACES", value="cores"),
            client.V1EnvVar(name="JOB_COMPLETION_INDEX", value_from=client.V1EnvVarSource(
                field_ref=client.V1ObjectFieldSelector(field_path="metadata.annotations['batch.kubernetes.io/job-completion-index']")
            ))
        ],
    )
    
    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"app": "tandem-job"}),
        spec=client.V1PodSpec(
            restart_policy="Never",
            containers=[container],
            volumes=[
                client.V1Volume(
                    name="yohai-magen-sse-pvc",
                    persistent_volume_claim=client.V1PersistentVolumeClaimVolumeSource(
                        claim_name="yohai-magen-sse-pvc"
                    ),
                )
            ],
        ),
    )
    
    job_spec = client.V1JobSpec(
        template=template,
        backoff_limit=3,
        completion_mode="Indexed",
        completions=k,
        parallelism=k,
    )
    
    job = client.V1Job(
        api_version="batch/v1",
        kind="Job",
        metadata=client.V1ObjectMeta(name=job_name),
        spec=job_spec,
    )
    
    # Save job YAML for debugging
    with open("tandem-batch-job_rerun_2.yaml", "w") as f:
        yaml.dump(client.ApiClient().sanitize_for_serialization(job), f)
    
    return job

def create_job(batch_v1, namespace, list1, list2, dry_run):
    # pairs = [(pair1, pair2) for pair1 in list1 for pair2 in list2]
    pairs = [(p1, p2) for p1, p2 in zip(list1, list2)]
    job = create_job_object(pairs)
    
    if dry_run:
        print("Dry run: Job YAML saved but not submitted.")
    else:
        batch_v1.create_namespaced_job(namespace=namespace, body=job)

def main():
    parser = argparse.ArgumentParser(description="Create Kubernetes Jobs for all pairs.")
    parser.add_argument("--dry-run", action="store_true", help="Save the YAML but do not submit the job.")
    args = parser.parse_args()
    
    config.load_kube_config()
    batch_v1 = client.BatchV1Api()
    namespace = "default"
    # list1 = ['62.5', '65', '67.5', '68.125', '68.75', '69.375', '70', '72.5', '75', '77.5', '82.5', '92.5', '100']  # Example values
    # list2 = ["1", "2", "3", "5", "6"]
    # list1 = ['82.5', '100.0', '77.5', '92.5', '72.5', '100.0', '68.125', '75.0', '65.0', '100.0', '100.0', '70.0', '69.375']
    # list2 = ['6.0', '2.0', '5.0', '3.0', '3.0', '6.0', '2.0', '5.0', '3.0', '5.0', '3.0', '5.0', '5.0']
    list1 = ['77.5', '72.5', '100.0', '68.125', '65.0', '70.0']
    list2 = ['5.0', '3.0', '6.0', '2.0', '3.0', '5.0']
    create_job(batch_v1, namespace, list1, list2, args.dry_run)

if __name__ == "__main__":
    main()
