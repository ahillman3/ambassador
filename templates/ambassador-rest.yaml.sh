HERE=$(dirname $0)
eval $(sh $HERE/../scripts/get_registries.sh)

cat <<EOF
---
apiVersion: v1
kind: Service
metadata:
  labels:
    service: ambassador-admin
  name: ambassador-admin
spec:
  type: NodePort
  ports:
  - name: ambassador-admin
    port: 8888
    targetPort: 8888
  selector:
    service: ambassador
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ambassador
spec:
  replicas: 1
  template:
    metadata:
      labels:
        service: ambassador
    spec:
      containers:
      - name: ambassador
        image: ${AMREG}ambassador:0.10.4
        resources:
          limits:
            cpu: 1
            memory: 400Mi
          requests:
            cpu: 200m
            memory: 100Mi
        volumeMounts:
        - mountPath: /etc/certs
          name: cert-data
        - mountPath: /etc/cacert
          name: cacert-data
      - name: statsd
        image: ${STREG}statsd:0.10.4
      volumes:
      - name: cert-data
        secret:
          secretName: ambassador-certs
      - name: cacert-data
        secret:
          secretName: ambassador-cacert
      restartPolicy: Always
EOF
