# crDroid-build-signed-script
Script for creating a signing build environment

## Disclaimer
This script only works for password-less keys (DO NOT SET A PASSWORD) *This is due to building inline, other steps are necessary for a password*

*Works with crDroid 8.x+ or lineage19.1+*

## How to run
1. Clone the repository

2. Run the script

`chmod +x create-signed-env.sh`

`./create-signed-env.sh`

3. Hit enter to set no password for each certificate. **Cannot set a password to build inline with this method!**

4. Create a link in your build environment to the ./vendor/lineage-priv folder

`ln -s ./crDroid-build-signed-script/vendor-crDroid/lineage-priv ./build_env/vendor/lineage-priv`

## Check the certs and the keys

`cd ./certs-crDroid/`

`openssl x509 -in cert.x509.pem -text -noout`

`openssl pkcs8 -inform DER -in key.pk8 -nocrypt -out key.pem`
`openssl rsa -in key.pem -text -noout`

## Prep device tree (for other ROMs)
In your device tree (or common device tree) add:

`-include vendor/lineage-priv/keys/keys.mk`

Build as usual!
