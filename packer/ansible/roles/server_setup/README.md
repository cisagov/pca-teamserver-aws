server_setup
============

A role for installing the ServerSetup tool.

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

    - hosts: teamservers
      become: yes
      become_method: sudo
      roles:
         - cobalt_strike

License
-------

BSD

Author Information
------------------

Shane Frasier <jeremy.frasier@beta.dhs.gov>
