# Service Mesh Demo on OpenShift4
This is a collection of scrtips for demonstrate Service Mesh on OpenShift4.
  
## How to start
First, you have to deploy the Service Mesh control plane on the OpenShift by running the following scripts, you may find more details by referencing [Installing Red Hat OpenShift Service Mesh](https://docs.openshift.com/container-platform/latest/service_mesh/v2x/installing-ossm.html)
```bash
./00-install-operator.sh
./01-deploy-control-plane.sh
```
## What to do next
If you don't know what to do next, you can deploy a well known application called "bookinfo" for testing Service Mesh by using the following scripts, then you can use the application to test different features. You may also find some of the scenario from below sections. More information -> [Deploy Bookinfo](https://docs.openshift.com/container-platform/latest/service_mesh/v2x/prepare-to-deploy-applications-ossm.html#ossm-tutorial-bookinfo-overview_deploying-applications-ossm) and [What is Bookinfo](https://istio.io/latest/docs/examples/bookinfo)
```bash
./10-bookinfo-deploy.sh
```
# Demo Scenarios
## [Request Routing](https://istio.io/latest/docs/tasks/traffic-management/request-routing/)
Without any virtual service, the behavior will be round-robin to all reviews services, this is the default behavior of OpenShift service.
### Route to V1
Follow the instruction after running the script.
```bash
./20-bookinfo-traffic-all-v1.sh
```
### [Route based on user identity](https://istio.io/latest/docs/tasks/traffic-management/request-routing/#route-based-on-user-identity)
Follow the instruction after running the script.
```bash
./21-bookinfo-traffic-jason-v2.sh
```
## Fault Injection
...TODO...

## mTLS
...TODO...

## References
- [Istio Docs](https://istio.io/docs/)
