# OpenVPN VNF Package

This repository will contain the sscripts and VNF packages needed to deploy a VPN server and VPN client onto OSM

## Steps

1. Install openvpn on both server and client (using apt for now)
2. Generate a static key or use a preconfigured (hard coded) one
3. Make sure the same static key is on the server and client
4. Create the configuration files `/etc/openvpn/config.opvn`
5. Create the systemd services and start them
6. Enable IP forwarding
7. Allow client to reach server subnet by adding a route to the client side and enabling IP Masquradeing on server side.

## OSM Descriptors

The Descriptors for the openvpn configuration can be found in the `osm-descriptors` folder in the package root. They are split into the `server` and `client` folders.

### Defining Descriptors - Virtual Network Functions 

Documentation: <http://osm-download.etsi.org/repository/osm/debian/ReleaseTEN/docs/osm-im/osm_im_trees/etsi-nfv-vnfd.html>

Load descriptor to OSM

```bash
tar -cvzf osm-descriptor/[server|client]/vnf_package.tar.gz vnf_package
osm vnfpkg-create vnf_package.tar.gz
```

## Defining Descriptors - Network Services

Documentation: <http://osm-download.etsi.org/repository/osm/debian/ReleaseTEN/docs/osm-im/osm_im_trees/etsi-nfv-nsd.html>

The descriptor must reference a pre-created subnet to deploy to, in the example provided this is set to 'vim-network-name: service'.

Load descriptor to OSM:

```bash
tar -cvzf osm-descriptor/[server|client]/ns_package.tar.gz ns_package
osm nspkg-create ns_package.tar.gz
```
