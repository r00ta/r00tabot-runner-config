#!/bin/bash

set -ex

echo "Logging in.."
retry_until_success_contains "maas login admin http://localhost:5240/MAAS `cat /tmp/api-key-file`" "You are now logged in to the MAAS server at"

echo "Setting maas_auto_ipmi_k_g_bmc_key configuration.."
maas admin maas set-config name=maas_auto_ipmi_k_g_bmc_key value=0x0000000000000000000000000000000000000000

echo "Retrieving maas_auto_ipmi_k_g_bmc_key configuration.."
VALUE=$(maas $MAAS_PROFILE maas get-config name=maas_auto_ipmi_k_g_bmc_key)
echo "$VALUE"
if [[ "$VALUE" != "0x0000000000000000000000000000000000000000" ]]; then
  echo "❌ Config value does not match expected value."
  exit 1
fi