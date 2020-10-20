# cloud-init commands for configuring non-root volumes and ssh

data "cloudinit_config" "teamserver_cloud_init_tasks" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "user_ssh_setup.yml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/scripts/user_ssh_setup.yml",
    {})
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "disk_setup.yml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/scripts/disk_setup.yml", {
        device = "/dev/nvme1n1"
    })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}
