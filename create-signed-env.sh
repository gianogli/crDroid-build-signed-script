#!/bin/bash

# LineageOS branch version (for repository android_development)
LINEAGEOS="22.2"

# Set my fixed parameters for the subject
country="IT"
state="Italy"
locality="Biella"
organization="crDroid-Unofficial"
organizational_unit="crDroid-Unofficial"
common_name="gianogli"
email="gianogli@tiscali.it"

# Construct the subject line
subject="/C=${country}/ST=${state}/L=${locality}/O=${organization}/OU=${organizational_unit}/CN=${common_name}/emailAddress=${email}"

# Print the subject line
echo -e "INFO: Your subject line: $subject\n"

# Download the official make_key script
mkdir -p ./script/
rm -f ./script/make_key
wget https://raw.githubusercontent.com/LineageOS/android_development/refs/heads/lineage-"${LINEAGEOS}"/tools/make_key --quiet -O ./script/make_key
chmod +x ./script/make_key

if [[ ! -f "./script/make_key" ]]; then
    echo -e "ERROR: Check if we can download the make_key script!\n"
    exit 1
fi

# Create the folders where generate the keys
rm -f ./certs-crDroid
rm -f ./vendor-crDroid
DATE=$(date +"%Y%m%d_%s")
mkdir -p ./certs-"${DATE}"
mkdir -p ./vendor-"${DATE}"/lineage-priv/keys
ln -s ./certs-"${DATE}" ./certs-crDroid
ln -s ./vendor-"${DATE}" ./vendor-crDroid

# Create the keys for ~/.android-certs/ folder
echo -e "INFO: Press ENTER to skip passwords (about 10-15 ENTER hits total). Cannot use a password for inline signing!\n"
echo -e "***********************************************************************************************\n"
for x in bluetooth media networkstack nfc platform releasekey sdk_sandbox shared testkey verifiedboot; do \
    ./script/make_key ./certs-crDroid/$x "$subject"; \
done
echo -e "***********************************************************************************************\n"

# Create the vendor folder for build the ROM
cp -a ./certs-crDroid/* ./vendor-crDroid/lineage-priv/keys/
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > ./vendor-crDroid/lineage-priv/keys/keys.mk
cat <<EOF > ./vendor-crDroid/lineage-priv/keys/BUILD.bazel
filegroup(
    name = "android_certificate_directory",
    srcs = glob([
        "*.pk8",
        "*.pem",
    ]),
    visibility = ["//visibility:public"],
)
EOF

# Create a backup of the new keys
tar -czf ./backup-vendor-crDroid-keys-"${DATE}".tgz -C ./vendor-crDroid/ .

echo "INFO: Done!"

exit 0
