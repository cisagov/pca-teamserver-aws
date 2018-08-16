dnsutils
========

A role for installing dnsutils.

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

    - hosts: dnsutils
      become: yes
      become_method: sudo
      roles:
         - dnsutils

License
-------

BSD

Author Information
------------------

Shane Frasier <jeremy.frasier@beta.dhs.gov>
