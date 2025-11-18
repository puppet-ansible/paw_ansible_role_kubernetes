# Puppet task for executing Ansible role: ansible_role_kubernetes
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_kubernetes"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_kubernetes"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_kubernetes\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_kubernetes"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_kubernetes"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_kubernetes_version) {
  $ExtraVars['kubernetes_version'] = $env:PT_kubernetes_version
}
if ($env:PT_kubernetes_config_kubeadm_apiversion) {
  $ExtraVars['kubernetes_config_kubeadm_apiversion'] = $env:PT_kubernetes_config_kubeadm_apiversion
}
if ($env:PT_kubenetes_config_kubelet_apiversion) {
  $ExtraVars['kubenetes_config_kubelet_apiversion'] = $env:PT_kubenetes_config_kubelet_apiversion
}
if ($env:PT_kubernetes_config_kubeproxy_apiversion) {
  $ExtraVars['kubernetes_config_kubeproxy_apiversion'] = $env:PT_kubernetes_config_kubeproxy_apiversion
}
if ($env:PT_kubernetes_packages) {
  $ExtraVars['kubernetes_packages'] = $env:PT_kubernetes_packages
}
if ($env:PT_kubernetes_version_rhel_package) {
  $ExtraVars['kubernetes_version_rhel_package'] = $env:PT_kubernetes_version_rhel_package
}
if ($env:PT_kubernetes_role) {
  $ExtraVars['kubernetes_role'] = $env:PT_kubernetes_role
}
if ($env:PT_kubernetes_kubelet_extra_args) {
  $ExtraVars['kubernetes_kubelet_extra_args'] = $env:PT_kubernetes_kubelet_extra_args
}
if ($env:PT_kubernetes_kubeadm_init_extra_opts) {
  $ExtraVars['kubernetes_kubeadm_init_extra_opts'] = $env:PT_kubernetes_kubeadm_init_extra_opts
}
if ($env:PT_kubernetes_join_command_extra_opts) {
  $ExtraVars['kubernetes_join_command_extra_opts'] = $env:PT_kubernetes_join_command_extra_opts
}
if ($env:PT_kubernetes_allow_pods_on_control_plane) {
  $ExtraVars['kubernetes_allow_pods_on_control_plane'] = $env:PT_kubernetes_allow_pods_on_control_plane
}
if ($env:PT_kubernetes_pod_network) {
  $ExtraVars['kubernetes_pod_network'] = $env:PT_kubernetes_pod_network
}
if ($env:PT_kubernetes_kubeadm_kubelet_config_file_path) {
  $ExtraVars['kubernetes_kubeadm_kubelet_config_file_path'] = $env:PT_kubernetes_kubeadm_kubelet_config_file_path
}
if ($env:PT_kubernetes_config_kubelet_configuration) {
  $ExtraVars['kubernetes_config_kubelet_configuration'] = $env:PT_kubernetes_config_kubelet_configuration
}
if ($env:PT_kubernetes_config_init_configuration) {
  $ExtraVars['kubernetes_config_init_configuration'] = $env:PT_kubernetes_config_init_configuration
}
if ($env:PT_kubernetes_config_cluster_configuration) {
  $ExtraVars['kubernetes_config_cluster_configuration'] = $env:PT_kubernetes_config_cluster_configuration
}
if ($env:PT_kubernetes_config_kube_proxy_configuration) {
  $ExtraVars['kubernetes_config_kube_proxy_configuration'] = $env:PT_kubernetes_config_kube_proxy_configuration
}
if ($env:PT_kubernetes_apiserver_advertise_address) {
  $ExtraVars['kubernetes_apiserver_advertise_address'] = $env:PT_kubernetes_apiserver_advertise_address
}
if ($env:PT_kubernetes_version_kubeadm) {
  $ExtraVars['kubernetes_version_kubeadm'] = $env:PT_kubernetes_version_kubeadm
}
if ($env:PT_kubernetes_ignore_preflight_errors) {
  $ExtraVars['kubernetes_ignore_preflight_errors'] = $env:PT_kubernetes_ignore_preflight_errors
}
if ($env:PT_kubernetes_apt_release_channel) {
  $ExtraVars['kubernetes_apt_release_channel'] = $env:PT_kubernetes_apt_release_channel
}
if ($env:PT_kubernetes_apt_repository) {
  $ExtraVars['kubernetes_apt_repository'] = $env:PT_kubernetes_apt_repository
}
if ($env:PT_kubernetes_yum_base_url) {
  $ExtraVars['kubernetes_yum_base_url'] = $env:PT_kubernetes_yum_base_url
}
if ($env:PT_kubernetes_yum_gpg_key) {
  $ExtraVars['kubernetes_yum_gpg_key'] = $env:PT_kubernetes_yum_gpg_key
}
if ($env:PT_kubernetes_yum_gpg_check) {
  $ExtraVars['kubernetes_yum_gpg_check'] = $env:PT_kubernetes_yum_gpg_check
}
if ($env:PT_kubernetes_yum_repo_gpg_check) {
  $ExtraVars['kubernetes_yum_repo_gpg_check'] = $env:PT_kubernetes_yum_repo_gpg_check
}
if ($env:PT_kubernetes_flannel_manifest_file) {
  $ExtraVars['kubernetes_flannel_manifest_file'] = $env:PT_kubernetes_flannel_manifest_file
}
if ($env:PT_kubernetes_calico_manifest_file) {
  $ExtraVars['kubernetes_calico_manifest_file'] = $env:PT_kubernetes_calico_manifest_file
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_kubernetes"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_kubernetes"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}
