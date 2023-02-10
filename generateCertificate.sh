#!/bin/bash
mkdir cert
openssl req -x509 -newkey rsa:4096 -keyout cert/private.key -out cert/cert.crt -sha256 -days 365 -nodes -subj "/C=DE/ST=NRW/L=Essen/O=Race4Hospiz/OU=Org/CN=teamcontrol.race4hospiz.de"