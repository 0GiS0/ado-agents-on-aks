kubectl create namespace linux-agents

kubectl create secret generic azdevops-pat --from-literal=personalAccessToken=$PAT -n linux-agents

cat <<EOF | kubectl apply -f -
# cat <<EOF > azdevops-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azdevops-deployment
  labels:
    app: azdevops-agent
  namespace: linux-agents
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
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azdevops-agent
        image: $ACR_NAME.azurecr.io/$LINUX_IMAGE_NAME:$IMAGE_ID
        env:
          - name: AZP_URL
            value: "https://dev.azure.com/$ORGANIZATION_NAME"
          - name: AZP_POOL
            value: "$LINUX_AGENT_POOL_NAME"
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
  namespace: linux-agents
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
  namespace: linux-agents
spec:
  scaleTargetRef:
    name: azdevops-deployment
  minReplicaCount: 1
  maxReplicaCount: 5 
  triggers:
  - type: azure-pipelines
    metadata:
      poolName: "$LINUX_AGENT_POOL_NAME"
      organizationURLFromEnv: "AZP_URL"
    authenticationRef:
     name: pipeline-trigger-auth
EOF

# VPA for the linux agents
cat <<EOF | kubectl apply -f -
apiVersion: "autoscaling.k8s.io/v1"
kind: VerticalPodAutoscaler
metadata:
  name: linux-agents-vpa
  namespace: linux-agents
spec:
  updatePolicy:
    updateMode: "Off"
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: azdevops-deployment
  resourcePolicy:
    containerPolicies:
      - containerName: '*'
        # minAllowed:
        #   cpu: 100m
        #   memory: 50Mi
        maxAllowed:
          cpu: 1
          memory: 3Gi
        controlledResources: ["cpu", "memory"]
EOF