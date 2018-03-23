# Automation

Scripts to automate all the things. Useful scripts for competitions.

# Iptables

`iptables.sh` must be configured before running automate.sh. Basic logging has been added to a few iptable rules. Monitor /var/log/kern.log (Debian) to find potential threats or to figure out how the scoring engine works.

**Useful command** `sudo tailf /var/log/kern.log | grep '*'`
> If you have your grep color set to auto then this will do some really nice highlighting for the iptables flags.

## Logging

Mastering the art of log monitoring will greatly increase your skills at competition. Creating custom iptable logs will help you out with figuring out the scoring engine and potential threats.

To log in iptables use the `-j LOG` flag. To add helpful flags use `-j LOG --log-prefix '** FLAG HERE ** '`.

i.e.
> `iptables -INPUT -s 127.0.0.1 -j LOG --log-prefix '** LOCALHOST ** '` adds a flag for local host traffic.
