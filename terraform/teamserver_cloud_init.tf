# cloud-init commands for configuring non-root volumes and ssh

data "template_file" "user_ssh_setup" {
  template = "${file("scripts/user_ssh_setup.yml")}"
}

data "template_file" "disk_setup" {
  template = "${file("scripts/disk_setup.yml")}"

  vars {
    device = "/dev/nvme1n1"
  }
}

data "template_cloudinit_config" "teamserver_cloud_init_tasks" {
  gzip = true
  base64_encode = true

  part {
    filename = "user_ssh_setup.yml"
    content_type = "text/cloud-config"
    content = "${data.template_file.user_ssh_setup.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename = "disk_setup.yml"
    content_type = "text/cloud-config"
    content = "${data.template_file.disk_setup.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}
