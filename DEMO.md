# Demo Unikernels


```
# Build an App
go build -o bbdays4it-v2

# Build a NanoVM Unikernel
ops image create bbdays4it -c nanovm.json -t gcp

# Build Unikraft Kernel
kraft pkg --name index.unikraft.io/<USERNAME>/<APP>:<TAG> --push .

# Deploy Unikraft Kernel 

# Build & Deploy Kraft Unikernel
kraft cloud deploy -p 443:8080 .

# Scale to 10 instances 
kraft cloud scale init {service_name} --master {instance_name} --min-size 10 --max-size 10 --warmup-time 1s --cooldown-time 1s

```