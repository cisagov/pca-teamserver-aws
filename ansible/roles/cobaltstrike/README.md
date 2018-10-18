cobaltstrike
============

An Ansible role for licensing and upgrading Cobalt Strike.

Requirements
------------

None

Role Variables
--------------

None

Dependencies
------------

None

Example Playbook
----------------

Here's how to use it in a playbook:

    - hosts: cobaltstrike
      become: yes
      become_method: sudo
      roles:
        - cobaltstrike

License
-------

BSD

Author Information
------------------

Shane Frasier <jeremy.frasier@beta.dhs.gov>
