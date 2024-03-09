kubectl create secret generic azdevops-pat --from-literal=personalAccessToken=$PAT

cat <<EOF | kubectl apply -f -
# cat <<EOF > azdevops-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azdevops-deployment
  labels:
    app: azdevops-agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azdevops-agent
  template:
    metadata:
      labels:
        app: azdevops-agent
    spec:
      containers:
      - name: azdevops-agent
        image: $ACR_NAME.azurecr.io/ado-agent:$IMAGE_ID
        env:
          - name: AZP_URL
            value: "https://dev.azure.com/$ORGANIZATION_NAME"
          - name: AZP_POOL
            value: "$AGENT_POOL_NAME"
          - name: AZP_TOKEN
            valueFrom:
              secretKeyRef:
                name: azdevops-pat
                key: personalAccessToken
        volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-volume
      volumes:
      - name: docker-volume
        hostPath:
          path: /var/run/docker.sock
EOF

# Let create KEDA configuration to scale the agents
# cat <<EOF > keda-config.yaml
cat <<EOF | kubectl apply -f -
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: pipeline-trigger-auth
spec:
  secretTargetRef:
    - parameter: personalAccessToken
      name: azdevops-pat
      key: personalAccessToken
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: azure-pipelines-scaledobject
spec:
  scaleTargetRef:
    name: azdevops-deployment
  minReplicaCount: 1
  maxReplicaCount: 5 
  triggers:
  - type: azure-pipelines
    metadata:
      poolName: "$AGENT_POOL_NAME"
      organizationURLFromEnv: "AZP_URL"
    authenticationRef:
     name: pipeline-trigger-auth
EOF