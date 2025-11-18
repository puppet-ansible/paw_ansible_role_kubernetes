#!/bin/bash
set -e

# Puppet task for executing Ansible role: ansible_role_kubernetes
# This script runs the entire role via ansible-playbook

# Determine the ansible modules directory
if [ -n "$PT__installdir" ]; then
  ANSIBLE_DIR="$PT__installdir/lib/puppet_x/ansible_modules/ansible_role_kubernetes"
else
  # Fallback to /opt/puppetlabs/puppet/cache/lib/puppet_x/ansible_modules
  ANSIBLE_DIR="/opt/puppetlabs/puppet/cache/lib/puppet_x/ansible_modules/ansible_role_kubernetes"
fi

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
  echo '{"_error": {"msg": "ansible-playbook command not found. Please install Ansible.", "kind": "puppet-ansible-converter/ansible-not-found"}}'
  exit 1
fi

# Check if the role directory exists
if [ ! -d "$ANSIBLE_DIR" ]; then
  echo "{\"_error\": {\"msg\": \"Ansible role directory not found: $ANSIBLE_DIR\", \"kind\": \"puppet-ansible-converter/role-not-found\"}}"
  exit 1
fi

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
if [ -d "$ANSIBLE_DIR/roles" ] && [ -f "$ANSIBLE_DIR/roles/paw_ansible_role_kubernetes/playbook.yml" ]; then
  # Collection structure
  PLAYBOOK_PATH="$ANSIBLE_DIR/roles/paw_ansible_role_kubernetes/playbook.yml"
  PLAYBOOK_DIR="$ANSIBLE_DIR/roles/paw_ansible_role_kubernetes"
elif [ -f "$ANSIBLE_DIR/playbook.yml" ]; then
  # Standalone role structure
  PLAYBOOK_PATH="$ANSIBLE_DIR/playbook.yml"
  PLAYBOOK_DIR="$ANSIBLE_DIR"
else
  echo "{\"_error\": {\"msg\": \"playbook.yml not found in $ANSIBLE_DIR or $ANSIBLE_DIR/roles/paw_ansible_role_kubernetes\", \"kind\": \"puppet-ansible-converter/playbook-not-found\"}}"
  exit 1
fi

# Build extra-vars from PT_* environment variables (excluding par_* control params)
EXTRA_VARS="{"
FIRST=true
if [ -n "$PT_kubernetes_version" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_version\": \"$PT_kubernetes_version\""
fi
if [ -n "$PT_kubernetes_config_kubeadm_apiversion" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_config_kubeadm_apiversion\": \"$PT_kubernetes_config_kubeadm_apiversion\""
fi
if [ -n "$PT_kubenetes_config_kubelet_apiversion" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubenetes_config_kubelet_apiversion\": \"$PT_kubenetes_config_kubelet_apiversion\""
fi
if [ -n "$PT_kubernetes_config_kubeproxy_apiversion" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_config_kubeproxy_apiversion\": \"$PT_kubernetes_config_kubeproxy_apiversion\""
fi
if [ -n "$PT_kubernetes_packages" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_packages\": \"$PT_kubernetes_packages\""
fi
if [ -n "$PT_kubernetes_version_rhel_package" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_version_rhel_package\": \"$PT_kubernetes_version_rhel_package\""
fi
if [ -n "$PT_kubernetes_role" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_role\": \"$PT_kubernetes_role\""
fi
if [ -n "$PT_kubernetes_kubelet_extra_args" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_kubelet_extra_args\": \"$PT_kubernetes_kubelet_extra_args\""
fi
if [ -n "$PT_kubernetes_kubeadm_init_extra_opts" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_kubeadm_init_extra_opts\": \"$PT_kubernetes_kubeadm_init_extra_opts\""
fi
if [ -n "$PT_kubernetes_join_command_extra_opts" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_join_command_extra_opts\": \"$PT_kubernetes_join_command_extra_opts\""
fi
if [ -n "$PT_kubernetes_allow_pods_on_control_plane" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_allow_pods_on_control_plane\": \"$PT_kubernetes_allow_pods_on_control_plane\""
fi
if [ -n "$PT_kubernetes_pod_network" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_pod_network\": \"$PT_kubernetes_pod_network\""
fi
if [ -n "$PT_kubernetes_kubeadm_kubelet_config_file_path" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_kubeadm_kubelet_config_file_path\": \"$PT_kubernetes_kubeadm_kubelet_config_file_path\""
fi
if [ -n "$PT_kubernetes_config_kubelet_configuration" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_config_kubelet_configuration\": \"$PT_kubernetes_config_kubelet_configuration\""
fi
if [ -n "$PT_kubernetes_config_init_configuration" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_config_init_configuration\": \"$PT_kubernetes_config_init_configuration\""
fi
if [ -n "$PT_kubernetes_config_cluster_configuration" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_config_cluster_configuration\": \"$PT_kubernetes_config_cluster_configuration\""
fi
if [ -n "$PT_kubernetes_config_kube_proxy_configuration" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_config_kube_proxy_configuration\": \"$PT_kubernetes_config_kube_proxy_configuration\""
fi
if [ -n "$PT_kubernetes_apiserver_advertise_address" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_apiserver_advertise_address\": \"$PT_kubernetes_apiserver_advertise_address\""
fi
if [ -n "$PT_kubernetes_version_kubeadm" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_version_kubeadm\": \"$PT_kubernetes_version_kubeadm\""
fi
if [ -n "$PT_kubernetes_ignore_preflight_errors" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_ignore_preflight_errors\": \"$PT_kubernetes_ignore_preflight_errors\""
fi
if [ -n "$PT_kubernetes_apt_release_channel" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_apt_release_channel\": \"$PT_kubernetes_apt_release_channel\""
fi
if [ -n "$PT_kubernetes_apt_repository" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_apt_repository\": \"$PT_kubernetes_apt_repository\""
fi
if [ -n "$PT_kubernetes_yum_base_url" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_yum_base_url\": \"$PT_kubernetes_yum_base_url\""
fi
if [ -n "$PT_kubernetes_yum_gpg_key" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_yum_gpg_key\": \"$PT_kubernetes_yum_gpg_key\""
fi
if [ -n "$PT_kubernetes_yum_gpg_check" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_yum_gpg_check\": \"$PT_kubernetes_yum_gpg_check\""
fi
if [ -n "$PT_kubernetes_yum_repo_gpg_check" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_yum_repo_gpg_check\": \"$PT_kubernetes_yum_repo_gpg_check\""
fi
if [ -n "$PT_kubernetes_flannel_manifest_file" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_flannel_manifest_file\": \"$PT_kubernetes_flannel_manifest_file\""
fi
if [ -n "$PT_kubernetes_calico_manifest_file" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"kubernetes_calico_manifest_file\": \"$PT_kubernetes_calico_manifest_file\""
fi
EXTRA_VARS="$EXTRA_VARS}"

# Build ansible-playbook command matching PAR provider exactly
# See: https://github.com/garrettrowell/puppet-par/blob/main/lib/puppet/provider/par/par.rb#L166
cd "$PLAYBOOK_DIR"

# Base command with inventory and connection (matching PAR)
ANSIBLE_CMD="ansible-playbook -i localhost, --connection=local"

# Add extra-vars (playbook variables)
ANSIBLE_CMD="$ANSIBLE_CMD -e \"$EXTRA_VARS\""

# Add tags if specified
if [ -n "$PT_par_tags" ]; then
  TAGS=$(echo "$PT_par_tags" | sed 's/\[//;s/\]//;s/"//g;s/,/,/g')
  ANSIBLE_CMD="$ANSIBLE_CMD --tags \"$TAGS\""
fi

# Add skip-tags if specified
if [ -n "$PT_par_skip_tags" ]; then
  SKIP_TAGS=$(echo "$PT_par_skip_tags" | sed 's/\[//;s/\]//;s/"//g;s/,/,/g')
  ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags \"$SKIP_TAGS\""
fi

# Add start-at-task if specified
if [ -n "$PT_par_start_at_task" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --start-at-task \"$PT_par_start_at_task\""
fi

# Add limit if specified
if [ -n "$PT_par_limit" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$PT_par_limit\""
fi

# Add verbose flag if specified
if [ "$PT_par_verbose" = "true" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD -v"
fi

# Add check mode flag if specified
if [ "$PT_par_check_mode" = "true" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --check"
fi

# Add user if specified
if [ -n "$PT_par_user" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --user \"$PT_par_user\""
fi

# Add timeout if specified
if [ -n "$PT_par_timeout" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --timeout $PT_par_timeout"
fi

# Add playbook path as last argument (matching PAR)
ANSIBLE_CMD="$ANSIBLE_CMD playbook.yml"

# Set environment variables if specified (matching PAR env_vars handling)
if [ -n "$PT_par_env_vars" ]; then
  # Parse JSON hash and export variables
  eval $(echo "$PT_par_env_vars" | sed 's/[{}]//g;s/": "/=/g;s/","/;export /g;s/"//g' | sed 's/^/export /')
fi

# Set required Ansible environment (matching PAR)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export ANSIBLE_STDOUT_CALLBACK=json

# Execute ansible-playbook
eval $ANSIBLE_CMD 2>&1

EXIT_CODE=$?

# Return JSON result
if [ $EXIT_CODE -eq 0 ]; then
  echo '{"status": "success", "role": "ansible_role_kubernetes"}'
else
  echo "{\"status\": \"failed\", \"role\": \"ansible_role_kubernetes\", \"exit_code\": $EXIT_CODE}"
fi

exit $EXIT_CODE
