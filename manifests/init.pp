# paw_ansible_role_kubernetes
# @summary Manage paw_ansible_role_kubernetes configuration
#
# @param kubernetes_version
# @param kubernetes_config_kubeadm_apiversion
# @param kubenetes_config_kubelet_apiversion
# @param kubernetes_config_kubeproxy_apiversion
# @param kubernetes_packages
# @param kubernetes_version_rhel_package
# @param kubernetes_role
# @param kubernetes_kubelet_extra_args This is deprecated. Please use kubernetes_config_kubelet_configuration instead.
# @param kubernetes_kubeadm_init_extra_opts
# @param kubernetes_join_command_extra_opts
# @param kubernetes_allow_pods_on_control_plane
# @param kubernetes_pod_network
# @param kubernetes_kubeadm_kubelet_config_file_path
# @param kubernetes_config_kubelet_configuration
# @param kubernetes_config_init_configuration
# @param kubernetes_config_cluster_configuration
# @param kubernetes_config_kube_proxy_configuration
# @param kubernetes_apiserver_advertise_address
# @param kubernetes_version_kubeadm
# @param kubernetes_ignore_preflight_errors
# @param kubernetes_apt_release_channel
# @param kubernetes_apt_repository
# @param kubernetes_yum_base_url
# @param kubernetes_yum_gpg_key
# @param kubernetes_yum_gpg_check
# @param kubernetes_yum_repo_gpg_check
# @param kubernetes_flannel_manifest_file Flannel config file.
# @param kubernetes_calico_manifest_file Calico config file.
# @param par_vardir Base directory for Puppet agent cache (uses lookup('paw::par_vardir') for common config)
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_kubernetes (
  String $kubernetes_version = '1.33',
  String $kubernetes_config_kubeadm_apiversion = 'v1beta4',
  String $kubenetes_config_kubelet_apiversion = 'v1beta1',
  String $kubernetes_config_kubeproxy_apiversion = 'v1alpha1',
  Array $kubernetes_packages = [{'name' => 'kubelet', 'state' => 'present'}, {'name' => 'kubectl', 'state' => 'present'}, {'name' => 'kubeadm', 'state' => 'present'}, {'name' => 'kubernetes-cni', 'state' => 'present'}],
  String $kubernetes_version_rhel_package = '1.33',
  String $kubernetes_role = 'control_plane',
  Optional[String] $kubernetes_kubelet_extra_args = undef,
  Optional[String] $kubernetes_kubeadm_init_extra_opts = undef,
  Optional[String] $kubernetes_join_command_extra_opts = undef,
  Boolean $kubernetes_allow_pods_on_control_plane = true,
  Hash $kubernetes_pod_network = {'cni' => 'flannel', 'cidr' => '10.244.0.0/16'},
  String $kubernetes_kubeadm_kubelet_config_file_path = '/etc/kubernetes/kubeadm-kubelet-config.yaml',
  Hash $kubernetes_config_kubelet_configuration = {'cgroupDriver' => 'systemd'},
  Hash $kubernetes_config_init_configuration = {'localAPIEndpoint' => {'advertiseAddress' => '{{ kubernetes_apiserver_advertise_address | default(ansible_default_ipv4.address, true) }}'}},
  Hash $kubernetes_config_cluster_configuration = {'networking' => {'podSubnet' => '{{ kubernetes_pod_network.cidr }}'}, 'kubernetesVersion' => '{{ kubernetes_version_kubeadm }}'},
  Hash $kubernetes_config_kube_proxy_configuration = {},
  Optional[String] $kubernetes_apiserver_advertise_address = undef,
  String $kubernetes_version_kubeadm = 'stable-{{ kubernetes_version }}',
  String $kubernetes_ignore_preflight_errors = 'all',
  String $kubernetes_apt_release_channel = 'stable',
  String $kubernetes_apt_repository = 'https://pkgs.k8s.io/core:/{{ kubernetes_apt_release_channel }}:/v{{ kubernetes_version }}/deb/',
  String $kubernetes_yum_base_url = 'https://pkgs.k8s.io/core:/stable:/v{{ kubernetes_version }}/rpm/',
  String $kubernetes_yum_gpg_key = 'https://pkgs.k8s.io/core:/stable:/v{{ kubernetes_version }}/rpm/repodata/repomd.xml.key',
  Boolean $kubernetes_yum_gpg_check = true,
  Boolean $kubernetes_yum_repo_gpg_check = true,
  String $kubernetes_flannel_manifest_file = 'https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml',
  String $kubernetes_calico_manifest_file = 'https://projectcalico.docs.tigera.io/manifests/calico.yaml',
  Optional[Stdlib::Absolutepath] $par_vardir = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
# Playbook synced via pluginsync to agent's cache directory
# Check for common paw::par_vardir setting, then module-specific, then default
$_par_vardir = $par_vardir ? {
  undef   => lookup('paw::par_vardir', Stdlib::Absolutepath, 'first', '/opt/puppetlabs/puppet/cache'),
  default => $par_vardir,
}
$playbook_path = "${_par_vardir}/lib/puppet_x/ansible_modules/ansible_role_kubernetes/playbook.yml"

par { 'paw_ansible_role_kubernetes-main':
  ensure        => present,
  playbook      => $playbook_path,
  playbook_vars => {
        'kubernetes_version' => $kubernetes_version,
        'kubernetes_config_kubeadm_apiversion' => $kubernetes_config_kubeadm_apiversion,
        'kubenetes_config_kubelet_apiversion' => $kubenetes_config_kubelet_apiversion,
        'kubernetes_config_kubeproxy_apiversion' => $kubernetes_config_kubeproxy_apiversion,
        'kubernetes_packages' => $kubernetes_packages,
        'kubernetes_version_rhel_package' => $kubernetes_version_rhel_package,
        'kubernetes_role' => $kubernetes_role,
        'kubernetes_kubelet_extra_args' => $kubernetes_kubelet_extra_args,
        'kubernetes_kubeadm_init_extra_opts' => $kubernetes_kubeadm_init_extra_opts,
        'kubernetes_join_command_extra_opts' => $kubernetes_join_command_extra_opts,
        'kubernetes_allow_pods_on_control_plane' => $kubernetes_allow_pods_on_control_plane,
        'kubernetes_pod_network' => $kubernetes_pod_network,
        'kubernetes_kubeadm_kubelet_config_file_path' => $kubernetes_kubeadm_kubelet_config_file_path,
        'kubernetes_config_kubelet_configuration' => $kubernetes_config_kubelet_configuration,
        'kubernetes_config_init_configuration' => $kubernetes_config_init_configuration,
        'kubernetes_config_cluster_configuration' => $kubernetes_config_cluster_configuration,
        'kubernetes_config_kube_proxy_configuration' => $kubernetes_config_kube_proxy_configuration,
        'kubernetes_apiserver_advertise_address' => $kubernetes_apiserver_advertise_address,
        'kubernetes_version_kubeadm' => $kubernetes_version_kubeadm,
        'kubernetes_ignore_preflight_errors' => $kubernetes_ignore_preflight_errors,
        'kubernetes_apt_release_channel' => $kubernetes_apt_release_channel,
        'kubernetes_apt_repository' => $kubernetes_apt_repository,
        'kubernetes_yum_base_url' => $kubernetes_yum_base_url,
        'kubernetes_yum_gpg_key' => $kubernetes_yum_gpg_key,
        'kubernetes_yum_gpg_check' => $kubernetes_yum_gpg_check,
        'kubernetes_yum_repo_gpg_check' => $kubernetes_yum_repo_gpg_check,
        'kubernetes_flannel_manifest_file' => $kubernetes_flannel_manifest_file,
        'kubernetes_calico_manifest_file' => $kubernetes_calico_manifest_file
              },
  tags          => $par_tags,
  skip_tags     => $par_skip_tags,
  start_at_task => $par_start_at_task,
  limit         => $par_limit,
  verbose       => $par_verbose,
  check_mode    => $par_check_mode,
  timeout       => $par_timeout,
  user          => $par_user,
  env_vars      => $par_env_vars,
  logoutput     => $par_logoutput,
  exclusive     => $par_exclusive,
}
}
