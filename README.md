## Description

A terraform and ansible config to deploy Tableau Server on RHEL 7.

## Software Requirements

Tested with:
* ansible 2.8.1
* terraform 0.12.3
* tableau-server 2019.2
* RHEL 7.6
* vSphere/vCenter 6.7

## Install

- AWS provider
```
coming soon
```
- vSphere provider
```
cd vsphere
```

## Self-signed SSL
```
openssl req -x509 -days 365 -newkey rsa:4096 \
-keyout tableau1.example.com.key.pass \
-out tableau1.example.com.crt \
-subj "/C=US/ST=NC/L=Charlotte/O=Example/OU=IT/CN=tableau1.example.com"

openssl rsa -in tableau1.example.com.key.pass -out tableau1.example.com.key

rm tableau1.example.com.key.pass
```
https://onlinehelp.tableau.com/current/server-linux/en-us/ssl_cert_create.htm

## SSO with JumpCloud
https://support.jumpcloud.com/customer/en/portal/articles/2780036-single-sign-on-sso-with-tableau-server
