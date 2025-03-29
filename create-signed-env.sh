#!/bin/bash

# LineageOS branch version (for repository android_development)
LINEAGEOS="22.2"

# Prompt the user for each part of the subject line
#read -p "Enter country code 'US' (C): " country
#read -p "Enter state or province name 'California' (ST): " state
#read -p "Enter locality 'Los Angeles' (L): " locality
#read -p "Enter organization name 'crDroid' (O): " organization
#read -p "Enter organizational unit 'crDroid' (OU): " organizational_unit
#read -p "Enter common name 'crdroid' (CN): " common_name
#read -p "Enter email address 'android@android.com' (emailAddress): " email

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
echo "Using Subject Line:"
echo "$subject"

# Prompt the user to verify if the subject line is correct
#read -p "Is the subject line correct? (y/n): " confirmation

# Check the user's response
#if [[ $confirmation != "y" && $confirmation != "Y" ]]; then
#    echo "Exiting without changes."
#    exit 1
#fi
#clear

# Download the official make_key script
mkdir -p ./script/
rm -f ./script/make_key
wget https://raw.githubusercontent.com/LineageOS/android_development/refs/heads/lineage-"${LINEAGEOS}"/tools/make_key --quiet -O ./script/make_key
chmod +x ./script/make_key

if [[ ! -f "./script/make_key" ]]; then
    echo "ERROR: Check if we can download the make_key script!"
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
echo "INFO: Press ENTER to skip passwords (about 10-15 ENTER hits total). Cannot use a password for inline signing!"
for x in bluetooth media networkstack nfc platform releasekey sdk_sandbox shared testkey verifiedboot; do \
    ./script/make_key ./certs-crDroid/$x "$subject"; \
done

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

echo "Done! Now build as usual. If builds aren't being signed, add '-include vendor/lineage-priv/keys/keys.mk' to your device mk file"
echo "Make copies of your vendor/lineage-priv folder as it contains your keys!"
sleep 3
