oracle_java_8
=============

A role for installing Oracle Java 8

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
         - oracle_java_8

License
-------

BSD

Author Information
------------------

Shane Frasier <jeremy.frasier@beta.dhs.gov>
